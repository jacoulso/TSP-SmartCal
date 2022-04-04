import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiserviceService {

  constructor(private _http: HttpClient) { }

  // connect frontend to backend 
  apiUrl = "http://localhost:3000";
  loginAuthPath = this.apiUrl + "/login";
  registerPath = this.apiUrl + "/singup";

  // login autherization
  getUserAuth(userCred: string, password: string): Observable<any> {
    console.log(`req ==> '${userCred}', '${password}'`);
    return this._http.get(this.loginAuthPath + `/${userCred}/${password}`);
  }

  // Register a new user
  registerUser(userCred: string, password: string, email: string): Observable<any> {
    console.log(`Creating user...`);
    return this._http.get(this.registerPath + `/${userCred}/${password}/${email}`);
  }
}
