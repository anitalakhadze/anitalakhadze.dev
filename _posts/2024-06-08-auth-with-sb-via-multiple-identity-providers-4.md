---
layout: post
title: "[Part 4] — Authentication with Multiple Identity Providers"
author: Ani Talakhadze
summary: Implementing Authentication with Spring Boot Security 6, OAuth2, and Angular 17 via Multiple Identity Providers - Developing A Minimal Angular Application
---

<figure>
    <img src="https://i.imgur.com/GSfq3xf.png" alt="Spring Boot Security 6, OAuth 2 and Angular 17" style="width:100%">
</figure>

Initially, I was quite hesitant to write this fourth and final part of the series because I wasn’t sure if readers were following along or finding it helpful. However, I was genuinely surprised when several people reached out, asking about the Angular section.

The general positive feedback and interest gave quite a motivation to me. So, I’m excited to present this final part, where we will develop a minimal Angular application to complete our multiple auth journey. The app will include Google, GitHub and username/password flows. You are welcome to extend them later according to your needs.

I strongly encourage you to review the previous parts to understand the whole problem we are trying to solve.

*NOTE* Even though initially I was planning to use Angular 17, at the moment of writing Angular 18 has already been released, so I changed to it instead. However, don’t worry, because there are no considerable differences between these versions for the purpose of our tutorial.

As usual, it’s best if you follow along, but if stuck, you can always check out the code in [my GitHub repository](https://github.com/anitalakhadze/multiple-auth-ui).


# Creating new Angular Project

Run the following CLI command in the directory of your choice to create a new workspace, and answer prompts about features to include (on question: “Do you want to enable Server-Side Rendering (SSR) and Static Site Generation
(SSG/Prerendering)?” choose “No”, we won’t need it):

```
ng new multiple-auth-ui
```

Change into the newly created directory:

```
cd multiple-auth-ui
```

Earlier the CLI created a default welcome app in the directory that can be built and served directly locally:

```
ng serve --open
```

You should see something like this:

<figure>
    <img src="https://i.imgur.com/DeSQfXf.png" alt="Default welcome app created by the Angular CLI" style="width:100%">
    <figcaption style="text-align: center;">
        Default welcome app created by the Angular CLI<br>
    </figcaption>
</figure>

As we won’t need this default setup, we should get rid of it. Open the workspace in your favorite IDE (mine is WebStorm by IntelliJ), and delete everything inside **app.component.html** file. After the app is automatically rebuilt, the browser will only display an empty page. That’s where we will start fresh.


# Setting up Angular project

Before we move on to handling redirection flows, let’s set up several handy components first. We will start by preparing constants for later usage:

```ts
export const API_BASE_URL = 'http://localhost:8080';
export const OAUTH2_AUTHORIZE_URI = '/oauth2/authorize';
export const UI_BASE_URL = 'http://localhost:4200';

export const ACCESS_TOKEN = 'accessToken';
export const ACCESS_TOKEN_HEADER_KEY = 'Authorization';

// separate redirect URIs are necessary to distinguish between the different OAuth2 providers

const GOOGLE_OAUTH2_REDIRECT_URI = `${UI_BASE_URL}/oauth2/google/redirect`;
export const GOOGLE_AUTH_URL = `${API_BASE_URL}${OAUTH2_AUTHORIZE_URI}/google?redirect_uri=${GOOGLE_OAUTH2_REDIRECT_URI}`;

const GITHUB_OAUTH2_REDIRECT_URI = `${UI_BASE_URL}/oauth2/github/redirect`;
export const GITHUB_AUTH_URL = `${API_BASE_URL}${OAUTH2_AUTHORIZE_URI}/github?redirect_uri=${GITHUB_OAUTH2_REDIRECT_URI}`;
```

Install **jwt-decode** library from the command-line to be able to parse and decode the tokens later:

```
npm i jwt-decode
```

Install **ngx-toaster** as well to be able to display success/error messages as notifications:

```
npm i ngx-toastr
```

Register necessary components in **app.config.ts**:

```ts
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { provideClientHydration } from '@angular/platform-browser';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import {provideHttpClient, withFetch, withInterceptors} from "@angular/common/http";
import {authenticationInterceptor} from "./auth/auth.interceptor";
import {provideToastr} from "ngx-toastr";

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideClientHydration(),
    provideAnimationsAsync(),
    provideToastr(),
    provideHttpClient(
      withFetch(), 
      withInterceptors([authenticationInterceptor])
    )
  ]
};
```

Finally, don’t forget to add **router-outlet** in the **app.component.html** so we can leverage routing:

```ts
<router-outlet></router-outlet>
```


# Setting up auth layers

Create a model for our authentication providers (‘local’ corresponds to the traditional username-password flow) and user’s profile that we will later use for displaying the information on the dashboard:

```ts
export enum AuthProvider {
  local = 'local',
  google = 'google',
  github = 'github',
  provider = 'provider'
}

export interface UserProfile {
  id: number,
  email: string,
  firstname: string,
  lastname: string
}
```

We will need `AuthService` that will be responsible for managing authentication state in the app. For the purposes of this tutorial, we will be using local storage for securing the access token (this is why we needed to disable ssr before).

```ts
import {Injectable} from "@angular/core";
import {Router} from "@angular/router";
import {ACCESS_TOKEN} from "../model/constants";
import {jwtDecode} from "jwt-decode";

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  parsedToken: any;
  authenticated: boolean = false;
  currentUser: any;

  constructor(public router: Router) {
    const token = this.getToken();
    if (token !== null && this.parsedToken == null) {
      this.parsedToken = jwtDecode(token);
    }
  }

  getToken() {
    return localStorage.getItem(ACCESS_TOKEN);
  }

  setAuthentication(accessToken: string) {
    localStorage.setItem(ACCESS_TOKEN, accessToken);
    this.authenticated = true;
  }

  logout() {
    localStorage.removeItem(ACCESS_TOKEN);
    this.authenticated = false;
    this.currentUser = null;
    this.router.navigate(['/login']);
  }

}
```

Next, define an HTTP interceptor that integrates with authentication and error handling services. This interceptor will add an authorization token to outgoing requests if one is available. It also handles errors by logging out the user if a forbidden status is received and displaying error messages using toast notifications.

```ts
import {HttpErrorResponse, HttpHandlerFn, HttpInterceptorFn, HttpRequest} from "@angular/common/http";
import {inject} from "@angular/core";
import {AuthService} from "./auth.service";
import {ToastrService} from "ngx-toastr";
import {ACCESS_TOKEN_HEADER_KEY} from "../model/constants";
import {catchError, throwError} from "rxjs";

export const authenticationInterceptor: HttpInterceptorFn = (req: HttpRequest<unknown>, next: HttpHandlerFn) => {
  const authService = inject(AuthService);
  const toastrService = inject(ToastrService);

  const authToken = authService.getToken();

  if (authToken) {
    req = req.clone({
      setHeaders: {
        [ACCESS_TOKEN_HEADER_KEY] : `Bearer ${authToken}`,
      },
    });
  }

  return next(req)
    .pipe(
      catchError((error: HttpErrorResponse) => {
        if (error.status === 403) {
          authService.logout();
        }

        const errorMessage = JSON.stringify(error.error, null, '\t');
        toastrService.error(errorMessage, 'Error!').onHidden
          .subscribe(() => {
            authService.logout();
          });

        return throwError(() => error);
      })
    )

}
```

We will also need a mechanism for guarding routes against the unauthenticated access. If the user is authenticated, it should grant access; otherwise, it should redirect the user to the login page.

```ts
import {Injectable} from "@angular/core";
import {ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot} from "@angular/router";
import {AuthService} from "./auth.service";

@Injectable({providedIn: 'root'})
export class AuthGuard implements CanActivate {
  constructor(
    private router: Router,
    private authService: AuthService
  ) {
  }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): any {
    if (this.authService.authenticated) {
      return true;
    } else {
      this.router.navigate(['/login']);
      return false;
    }
  }
}
```


# OAuth2 Redirect Handler Component

When a user goes through the social login provider authentication process, the backend app will receive the result — successful or unsuccessful one. In case of a successful flow, the backend app will authenticate the user, update the security context and send token to the frontend app. If no token has been provided, it means that authentication was invalid.

Create `OAuth2RedirectHandlerComponent` that will serve exactly the above purpose.

```ts
import {Component, OnInit} from '@angular/core';
import {AuthProvider} from "../../model/model";
import {ActivatedRoute, Router} from "@angular/router";
import {AuthService} from "../../auth/auth.service";
import {ToastrService} from "ngx-toastr";

@Component({
  selector: 'app-oauth2-redirect-handler',
  standalone: true,
  imports: [],
  templateUrl: './oauth2-redirect-handler.component.html',
  styleUrl: './oauth2-redirect-handler.component.css'
})
export class Oauth2RedirectHandlerComponent implements OnInit {

  token!: string;
  error!: string;
  authProvider: AuthProvider = AuthProvider.provider;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private authService: AuthService,
    private toastrService: ToastrService
  ) {
  }

  ngOnInit() {
    this.route.paramMap.subscribe(params => {
      this.authProvider = params.get('provider') as AuthProvider;
    })

    this.route.queryParams.subscribe(params => {
      this.token = params['token'];
      this.error = params['error'];

      if (this.token) {
        this.authService.setAuthentication(this.token);
        this.router.navigate(
          ['/dashboard/profile', this.authProvider],
          {state: {from: this.router.routerState.snapshot.url}}
        )
      } else {
        this.toastrService.error(this.error, 'Error!');
        this.router.navigate(
          ['/login'],
          {state: {from: this.router.routerState.snapshot.url, error: this.error}});
      }
    })
  }

}
```

# Login component

In this section we will develop a simple component that will display the different login options to the user and serve as an entry point for our application.

Start by creating `ApiService` component that will handle making the login call and getting authenticated user’s information:

```ts
import {Injectable} from "@angular/core";
import {HttpClient, HttpHeaders} from "@angular/common/http";
import {catchError, Observable, throwError} from "rxjs";
import {ACCESS_TOKEN, API_BASE_URL} from "../model/constants";
import {UserProfile} from "../model/model";

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  constructor(private http: HttpClient) { }

  private request(options: any): Observable<any> {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
    });

    if (localStorage.getItem(ACCESS_TOKEN)) {
      headers.append('Authorization', 'Bearer ' + localStorage.getItem(ACCESS_TOKEN));
    }

    const defaults = { headers: headers };
    options = Object.assign({}, defaults, options);

    return this.http.request(options.method, options.url, options)
      .pipe(
        catchError(error => {
          return throwError(() => error);
        })
      );
  }

  getCurrentUser(): Observable<any> {
    if (!localStorage.getItem(ACCESS_TOKEN)) {
      return throwError(() => new Error('No access token set.'));
    }

    return this.request({
      url: `${API_BASE_URL}/user/me`,
      method: 'GET'
    });
  }

  login(loginRequest: any): Observable<any> {
    return this.request({
      url: `${API_BASE_URL}/auth/login`,
      method: 'POST',
      body: JSON.stringify(loginRequest)
    });
  }

  getUserInfo(): Observable<UserProfile> {
    return this.request({
      url: `${API_BASE_URL}/user/me`,
      method: 'GET'
    });
  }

}
```

Now we are ready to start implementing the `Login` component itself:

```ts
import {Component, OnInit} from '@angular/core';
import {AuthProvider} from "../../model/model";
import {FormBuilder, FormGroup, ReactiveFormsModule, Validators} from "@angular/forms";
import {ActivatedRoute, Router} from "@angular/router";
import {ToastrService} from "ngx-toastr";
import {AuthService} from "../../auth/auth.service";
import {GITHUB_AUTH_URL, GOOGLE_AUTH_URL} from "../../model/constants";
import {ApiService} from "../../api/api.service";
import {MatFormField, MatLabel} from "@angular/material/form-field";
import {MatCard, MatCardContent, MatCardHeader, MatCardTitle} from "@angular/material/card";
import {MatIcon} from "@angular/material/icon";
import {MatButton, MatIconButton} from "@angular/material/button";
import {MatInput} from "@angular/material/input";

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatFormField,
    MatCard,
    MatCardHeader,
    MatCardContent,
    MatIcon,
    MatIconButton,
    MatInput,
    MatButton,
    MatFormField,
    MatLabel,
    MatCardTitle
  ],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent implements OnInit {
  authProvider?: AuthProvider;
  loginForm!: FormGroup;
  loading = false;
  submitted = false;

  errorResponse: boolean = false;
  errorMessage: string = '';

  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private toastrService: ToastrService,
    private authService: AuthService,
    private apiService: ApiService
  ) {
  }

  ngOnInit() {
    this.loginForm = this.formBuilder.group({
      email: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  onSubmit() {
    this.errorResponse = false;
    this.submitted = true;

    if (this.loginForm.invalid) {
      return;
    }

    this.loading = true;
    this.apiService.login(this.loginForm.value)
      .subscribe({
        next: data => {
          const token = JSON.parse(JSON.stringify(data)).accessToken;
          if (token) {
            this.authProvider = AuthProvider.local;
            this.authService.setAuthentication(token);
            this.router.navigate(['/dashboard/profile', this.authProvider], {state: {from: this.router.routerState.snapshot.url}});
          } else {
            this.errorResponse = true;
            this.errorMessage = "Authentication failed.";
          }
        },
        error: error => {
          this.errorResponse = true;
          this.errorMessage = error.error.message;
          this.loading = false;
        }
      });
  }

  loginWithProvider(provider: AuthProvider) {
    switch (provider) {
      case AuthProvider.google:
        window.location.href = GOOGLE_AUTH_URL;
        break;
      case AuthProvider.github:
        window.location.href = GITHUB_AUTH_URL;
        break;
      default:
        this.toastrService.error('Unknown provider');
    }
  }

  protected readonly AuthProvider = AuthProvider;

}
```

Add the following to the corresponding html file:

```html
<div class="mat-card-container">
  <mat-card class="login-form">
    <mat-card-header class="center-aligned">
      <mat-card-title class="card-title">
        <h1>Log in to the application!</h1>
      </mat-card-title>
    </mat-card-header>

    <mat-card-content>

      <div class="social-login-container">
        <div class="social-login-buttons">
          <button mat-icon-button color="primary" (click)="loginWithProvider(AuthProvider.google)">
            <mat-icon svgIcon="google_logo"></mat-icon>
          </button>

          <button mat-icon-button color="primary" (click)="loginWithProvider(AuthProvider.github)">
            <mat-icon svgIcon="github_logo"></mat-icon>
          </button>
        </div>
      </div>

      <form [formGroup]="loginForm">
        <mat-form-field class="form-group">
          <mat-label>Email</mat-label>
          <input matInput
                 type="text"
                 formControlName="email">
        </mat-form-field>

        <mat-form-field class="form-group">
          <mat-label>Password</mat-label>
          <input matInput
                 type="password"
                 formControlName="password">
        </mat-form-field>

        <div class="form-group">
          <button mat-raised-button
                  class="form-button"
                  type="submit"
                  color="primary"
                  [disabled]="loginForm.invalid || loading"
                  (click)="onSubmit()">
            Log In
          </button>
        </div>

        <div ngIf="errorResponse" class="error-text">
          <p>{{errorMessage}}</p>
        </div>
      </form>

    </mat-card-content>

  </mat-card>
</div>
```

# Dashboard Component

Create `Dashboard` component, that will be the home base for the user interaction:

```ts
import {Component, OnInit} from '@angular/core';
import {MatToolbar} from "@angular/material/toolbar";
import {MatIcon} from "@angular/material/icon";
import {RouterOutlet} from "@angular/router";
import {ApiService} from "../../api/api.service";
import {AuthService} from "../../auth/auth.service";
import {catchError, EMPTY, tap} from "rxjs";
import {response} from "express";
import {MatIconButton} from "@angular/material/button";
import {NgIf} from "@angular/common";

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    MatToolbar,
    MatIcon,
    RouterOutlet,
    MatIconButton,
    NgIf
  ],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css'
})
export class DashboardComponent implements OnInit {

  constructor(
    private apiService: ApiService,
    public authService: AuthService
  ) {
  }

  ngOnInit() {
    this.loadCurrentlyLoggedInUser();
  }

  loadCurrentlyLoggedInUser() {
    this.apiService.getCurrentUser()
      .pipe(
        tap(response => {
          this.authService.authenticated = true;
        }),
        catchError(err => {
          return EMPTY;
        })
      )
  }

}
```

And a corresponding html file:

```html
<div>
  <mat-toolbar color="primary" *ngIf="authService.authenticated">

    <span class="header">User Console</span>

    <span class="example-spacer"></span>

    <button
      mat-icon-button
      class="example-icon favorite-icon"
      (click)="authService.logout()">
      <mat-icon class="mat-icon-large">logout</mat-icon>
    </button>

  </mat-toolbar>

</div>

<router-outlet></router-outlet>
```

# User Profile Component

We will need a simple component for displaying the information retrieved from backend about the authenticated user.

```ts
import {Component, OnInit} from '@angular/core';
import {AuthProvider, UserProfile} from "../../model/model";
import {ActivatedRoute} from "@angular/router";
import {AuthService} from "../../auth/auth.service";
import {ToastrService} from "ngx-toastr";
import {ApiService} from "../../api/api.service";
import {ACCESS_TOKEN} from "../../model/constants";
import {NgIf} from "@angular/common";

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [
    NgIf
  ],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.css'
})
export class ProfileComponent implements OnInit {
  authProvider: AuthProvider = AuthProvider.provider;
  token!: string;
  userInfo!: UserProfile;

  constructor(
    private apiService: ApiService,
    private toastrService: ToastrService,
    private authService: AuthService,
    private route: ActivatedRoute
  ) {
  }

  ngOnInit(): void {
    this.route.paramMap.subscribe(params => {
      this.authProvider = params.get('authProvider') as AuthProvider;
    });

    let item = localStorage.getItem(ACCESS_TOKEN);
    if (item) {
      this.token = item;

      this.apiService.getUserInfo()
        .subscribe({
          next: (data) => {
            this.userInfo = data;
          },
          error: (error) => {
            this.toastrService.error(JSON.stringify(error.error.message, null, '\t'));
          }
        })
    } else {
      this.authService.logout();
    }
  }

  getAuthProviderDisplayName(authProvider: AuthProvider): string {
    switch (authProvider) {
      case AuthProvider.github:
        return 'GitHub';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.local:
        return 'Email/Password';
      default:
        return 'Unknown';
    }
  }

}
```

and html:

{% raw %}
```html
<div class="profile-container" *ngIf="userInfo">
  <div class="profile-info">
    <div class="profile-name">
      <h2>You are logged in using {{ getAuthProviderDisplayName(authProvider) }}</h2>
      <p class="profile-field">Email: {{ userInfo.email }}</p>
      <p class="profile-field">First Name: {{ userInfo.firstname }}</p>
      <p class="profile-field">Last Name: {{ userInfo.lastname }}</p>
    </div>
  </div>
</div>
```
{% endraw %}

and css:

```css
.profile-container {
  padding-top: 30px;
}

.profile-info {
  text-align: center;
}

.profile-info .profile-name {
  font-weight: 500;
  font-size: 18px;
}

.profile-info .profile-field {
  font-weight: 400;
}
```

# Styling the Application

First, we will import material UI module, for easy styling:

```
ng add @angular/material
```

I would also like to install specific svg icons for Google and GitHub. For that, after adding the svg files to the `assets/icons` folder, modify the `app.component.ts` accordingly:

```ts
import {Component, inject} from '@angular/core';
import { RouterOutlet } from '@angular/router';
import {MatIconRegistry} from "@angular/material/icon";
import {DomSanitizer} from "@angular/platform-browser";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'multiple-auth-ui';

private matIconRegistry = inject(MatIconRegistry);
  private domSanitizer = inject(DomSanitizer);

constructor() {
    this.initSvgIcons();
  }

private initSvgIcons() {
    this.matIconRegistry.addSvgIcon(
      'google_logo',
      this.domSanitizer.bypassSecurityTrustResourceUrl(
        '../assets/icons/google_logo.svg'
      )
    );
    this.matIconRegistry.addSvgIcon(
      'github_logo',
      this.domSanitizer.bypassSecurityTrustResourceUrl(
        '../assets/icons/github_logo.svg'
      )
    );
  }
}
```

And add the icons folder to the assets declaration in `angular.json` file:

```json
...
"assets": [
  {
    "glob": "**/*",
    "input": "public"
  },
  "src/assets/icons"
]
...
```

Next, include the following in the global `styles.css`:

```css
@import "@angular/material/prebuilt-themes/indigo-pink.css";

html, body {
  height: 100%;
}

body {
  margin: 0; font-family: Roboto, "Helvetica Neue", sans-serif;
  background-color: #f0f0f0;
}

.example-spacer {
  flex: 1 1 auto;
}

.header {
  font-weight: bold;
  font-size: 20px;
}

.mat-icon-large {
  transform: scale(1.5);
}

.form-group {
  width: 100%;
  margin-top: 15px;
}

.mat-card-container {
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
}

.center-aligned {
  text-align: center;
  margin-left: auto;
  margin-right: auto;
  padding: 20px;
}

.form-button {
  margin-left: auto;
  margin-right: auto;
  display: block !important;
}

.card-title {
  font-size: medium !important;
}

.login-form {
  width: 35%;
  padding: 35px;
  border-radius: 35px !important;
}

.social-login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding-top: 10px;
  padding-bottom: 10px;
}

.social-login-buttons {
  display: flex;
  gap: 35px;
}

.social-login-buttons button {
  font-size: 20px;
  padding: 10px; 
  transform: scale(1.5);
}

.error-text {
  color: rgb(192, 54, 54);
  font-size: large;
  text-align: center;
  margin-top: 10px;
}
```

Last, configure the routes in the following manner.

```ts
import {Routes} from '@angular/router';
import {AuthGuard} from "./auth/auth.guard";
import {Oauth2RedirectHandlerComponent} from "./auth/oauth2-redirect-handler/oauth2-redirect-handler.component";
import {LoginComponent} from "./user/login/login.component";
import {DashboardComponent} from "./user/dashboard/dashboard.component";
import {ProfileComponent} from "./user/profile/profile.component";

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'login'},
  { path: 'login', component: LoginComponent },
  { path: 'oauth2/:provider/redirect', component: Oauth2RedirectHandlerComponent },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [AuthGuard],
    children: [
      { path: 'profile/:authProvider', component: ProfileComponent, canActivate: [AuthGuard] }
    ]
  },
  { path: '**', redirectTo: 'login' }
];
```

# Changes in Backend Project

While developing the Angular project, I identified some necessary changes in the backend code and discovered a few issues that I previously overlooked. Please take the time to review these details; otherwise, the stacks may not connect properly. Below, I have included the modified classes. You can find each updated file in the [part-4](https://github.com/anitalakhadze/multiple-auth-api/tree/tutorial/part-4) branch or check out the complete solution in the [main](https://github.com/anitalakhadze/multiple-auth-api) branch.

`UserPrincipal.java`:

```java
@Data
public class UserPrincipal implements OAuth2User, UserDetails {
    private Long id;
    private String email;
    private String password;
    private Collection<? extends GrantedAuthority> authorities;
    private Map<String, Object> attributes;

    public UserPrincipal(Long id,
                         String email,
                         String password,
                         Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.authorities = authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public Map<String, Object> getAttributes() {
        return null;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getName() {
        return String.valueOf(id);
    }

    public static UserPrincipal create(User user) {
        List<GrantedAuthority> authorities = List.of(); // can be implemented later if needed

        return new UserPrincipal(
                user.getId(),
                user.getEmail(),
                user.getPassword(),
                authorities
        );
    }

    public static UserPrincipal create(User user, Map<String, Object> attributes) {
        UserPrincipal userPrincipal = UserPrincipal.create(user);
        userPrincipal.setAttributes(attributes);
        return userPrincipal;
    }
}
```

`TokenAuthenticationFilter.java`:

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class TokenAuthenticationFilter extends OncePerRequestFilter {

    private final TokenProvider tokenProvider;
    private final CustomUserDetailsService userDetailsService;


    private String getJWTFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring("Bearer ".length());
        }

        return null;
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        try {
            String jwt = getJWTFromRequest(request);

            if (StringUtils.hasText(jwt) && tokenProvider.validateToken(jwt)) {
                Long userId = tokenProvider.getUserIdFromToken(jwt);
                UserDetails userDetails = userDetailsService.loadUserById(userId);
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            log.error("Could not set user authentication in security context.", ex);
        }

        filterChain.doFilter(request, response);
    }

}
```

`SecurityConfig.java`:

```java
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final static String OAUTH2_BASE_URI = "/oauth2/authorize";
    private final static String OAUTH2_REDIRECTION_ENDPOINT = "/oauth2/callback/*";

    private final CustomOAuth2UserService customOAuth2UserService;
    private final OAuth2AuthenticationFailureHandler oAuth2AuthenticationFailureHandler;
    private final OAuth2AuthenticationSuccessHandler oAuth2AuthenticationSuccessHandler;
    private final HttpCookieOAuth2AuthorizationRequestRepository httpCookieOAuth2AuthorizationRequestRepository;
    private final TokenAuthenticationFilter tokenAuthenticationFilter;
    private final ClientRegistrationRepository clientRegistrationRepository;


    @Bean
    public HttpCookieOAuth2AuthorizationRequestRepository cookieOAuth2AuthorizationRequestRepository() {
        return new HttpCookieOAuth2AuthorizationRequestRepository();
    }

    @Bean
    protected SecurityFilterChain configure(HttpSecurity http) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable);
        http.cors(Customizer.withDefaults());
        http.sessionManagement(sessionManagement -> sessionManagement.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        http.formLogin(AbstractHttpConfigurer::disable);
        http.httpBasic(AbstractHttpConfigurer::disable);

        http.authorizeHttpRequests(
          auth -> auth
                  .requestMatchers("/token/refresh/**").permitAll()
                  .requestMatchers("/", "/error").permitAll()
                  .requestMatchers("/auth/**", "/oauth2/**").permitAll()
                  .anyRequest()
                  .authenticated()
        );

        http
                .oauth2Login(oauth2 -> oauth2
                        .authorizationEndpoint(authorizationEndpointConfig -> authorizationEndpointConfig
                                .baseUri(OAUTH2_BASE_URI)
                                .authorizationRequestRepository(httpCookieOAuth2AuthorizationRequestRepository)
                                .authorizationRequestResolver(new CustomAuthorizationRequestResolver(clientRegistrationRepository, OAUTH2_BASE_URI))
                        )
                        .redirectionEndpoint(redirectionEndpointConfig -> redirectionEndpointConfig.baseUri(OAUTH2_REDIRECTION_ENDPOINT))
                        .userInfoEndpoint(userInfoEndpointConfig -> userInfoEndpointConfig.userService(customOAuth2UserService))
                        .tokenEndpoint(tokenEndpointConfig -> tokenEndpointConfig.accessTokenResponseClient(authorizationCodeTokenResponseClient()))
                        .successHandler(oAuth2AuthenticationSuccessHandler)
                        .failureHandler(oAuth2AuthenticationFailureHandler)
                );

        http.addFilterBefore(tokenAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    private OAuth2AccessTokenResponseClient<OAuth2AuthorizationCodeGrantRequest> authorizationCodeTokenResponseClient() {
        OAuth2AccessTokenResponseHttpMessageConverter tokenResponseHttpMessageConverter = new OAuth2AccessTokenResponseHttpMessageConverter();
        tokenResponseHttpMessageConverter.setAccessTokenResponseConverter(new CustomAccessTokenResponseConverter());

        RestTemplate restTemplate = new RestTemplate(Arrays.asList(new FormHttpMessageConverter(), tokenResponseHttpMessageConverter));
        restTemplate.setErrorHandler(new OAuth2ErrorResponseErrorHandler());

        DefaultAuthorizationCodeTokenResponseClient tokenResponseClient = new DefaultAuthorizationCodeTokenResponseClient();
        tokenResponseClient.setRestOperations(restTemplate);

        return tokenResponseClient;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

}
```

`CustomAuthorizationRequestResolver.java`:

```java
public class CustomAuthorizationRequestResolver implements OAuth2AuthorizationRequestResolver {

    private final OAuth2AuthorizationRequestResolver defaultResolver;
    private final StringKeyGenerator secureKeyGenerator = new Base64StringKeyGenerator(Base64.getUrlEncoder().withoutPadding(), 96);

    public CustomAuthorizationRequestResolver(ClientRegistrationRepository repo, String authorizationRequestBaseUri) {
        defaultResolver = new DefaultOAuth2AuthorizationRequestResolver(repo, authorizationRequestBaseUri);
    }

    @Override
    public OAuth2AuthorizationRequest resolve(HttpServletRequest request) {
        OAuth2AuthorizationRequest req = defaultResolver.resolve(request);
        return customizeAuthorizationRequest(req);
    }

    @Override
    public OAuth2AuthorizationRequest resolve(HttpServletRequest request, String clientRegistrationId) {
        OAuth2AuthorizationRequest req = defaultResolver.resolve(request, clientRegistrationId);
        return customizeAuthorizationRequest(req);
    }


    private OAuth2AuthorizationRequest customizeAuthorizationRequest(OAuth2AuthorizationRequest req) {
        if (Objects.isNull(req)) {
            return null;
        }

        Map<String, Object> attributes = new HashMap<>(req.getAttributes());
        Map<String, Object> additionalParameters = new HashMap<>(req.getAdditionalParameters());
        addPkceParameters(attributes, additionalParameters);
        return OAuth2AuthorizationRequest.from(req)
                .attributes(attributes)
                .additionalParameters(additionalParameters)
                .build();
    }

    private void addPkceParameters(Map<String, Object> attributes, Map<String, Object> additionalParameters) {
        String codeVerifier = this.secureKeyGenerator.generateKey();
        attributes.put(PkceParameterNames.CODE_VERIFIER, codeVerifier);
        try {
            String codeChallenge = createHash(codeVerifier);
            additionalParameters.put(PkceParameterNames.CODE_CHALLENGE, codeChallenge);
            additionalParameters.put(PkceParameterNames.CODE_CHALLENGE_METHOD, "S256");
        } catch (NoSuchAlgorithmException e) {
            additionalParameters.put(PkceParameterNames.CODE_CHALLENGE, codeVerifier);
        }
    }

    private static String createHash(String value) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] digest = md.digest(value.getBytes(StandardCharsets.US_ASCII));
        return Base64.getUrlEncoder().withoutPadding().encodeToString(digest);
    }
}
```

and `application.properties`:

```
#Database configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/auth
spring.datasource.username=${DATABASE_USER}
spring.datasource.password=${DATABASE_PASSWORD}
spring.jpa.hibernate.ddl-auto=update
spring.datasource.driver-class-name=org.postgresql.Driver

# Google OAuth2 Configuration
spring.security.oauth2.client.registration.google.clientId=${GOOGLE_CLIENT_ID}
spring.security.oauth2.client.registration.google.clientSecret=${GOOGLE_CLIENT_SECRET}
spring.security.oauth2.client.registration.google.redirectUri={baseUrl}/oauth2/callback/{registrationId}
spring.security.oauth2.client.registration.google.scope=email, profile

# GitHub OAuth2 Configuration
spring.security.oauth2.client.registration.github.clientId=${GITHUB_CLIENT_ID}
spring.security.oauth2.client.registration.github.clientSecret=${GITHUB_CLIENT_SECRET}
spring.security.oauth2.client.registration.github.redirectUri={baseUrl}/oauth2/callback/{registrationId}
spring.security.oauth2.client.registration.github.scope=user:email, read:user

app.auth.tokenSecret=${AUTH_TOKEN_SECRET}
app.auth.tokenExpirationMsec=864000000
app.oauth2.authorizedRedirectUris=http://localhost:4200/oauth2/redirect
```

# Final Result

Finally, open the database in backend (or use CLI if preferred) and add the user to be able to login (you can create a separate admin application for user registration later):

<figure>
    <img src="https://i.imgur.com/Xko8RrO.png" alt="Registering user in the database to enable logging in" style="width:100%">
    <figcaption style="text-align: center;">
        Registering user in the database to enable logging in<br>
    </figcaption>
</figure>

**And… drum roll, please:**

<figure>
    <img src="https://i.imgur.com/CHdu04o.gif" alt="Demonstrating different login flows" style="width:100%">
    <figcaption style="text-align: center;">
        Demonstrating different login flows<br>
    </figcaption>
</figure>

**NOTE* Business requirements do not limit the user to use any or all combinations of logging in.*

---

Of course, the frontend application is not perfect or fancy, but it should provide a solid foundation for you to extend later as needed. I have updated the README files for both projects to help you get started with the applications.

Please share your thoughts and feedback in the comments, and let me know what topics you would like to read about in future blogs. After all, a good blog is one that interests its audience, right?