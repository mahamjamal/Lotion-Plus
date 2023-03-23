
// import ReactDOM from "react-dom/client";
// import { BrowserRouter, Route, Routes } from "react-router-dom";
// import Layout from "./Layout";
// import WriteBox from "./WriteBox";
// import Empty from "./Empty";
// import reportWebVitals from "./reportWebVitals";
// import { GoogleOAuthProvider } from '@react-oauth/google';
import React, { useState, useEffect } from 'react';
import { googleLogout, useGoogleLogin } from '@react-oauth/google';
import axios from 'axios';



function Login() {

    const [ user, setUser ] = useState([]);
    const [ profile, setProfile ] = useState([]);

    const login = useGoogleLogin({
        onSuccess: (codeResponse) => setUser(codeResponse),
        onError: (error) => console.log('Login Failed:', error)
    });

    useEffect(
        () => {
            if (user) {
                axios
                    .get(`https://www.googleapis.com/oauth2/v1/userinfo?access_token=${user.access_token}`, {
                        headers: {
                            Authorization: `Bearer ${user.access_token}`,
                            Accept: 'application/json'
                        }
                    })
                    .then((res) => {
                        setProfile(res.data);
                    })
                    .catch((err) => console.log(err));
            }
        },
        [ user ]
    );

    // log out function to log the user out of google and set the profile array to null
    const logOut = () => {
        googleLogout();
        setProfile(null);
    };

    return (
        <div>

    <header>
        <div id="app-header">
          <h1>
            Lotion
          </h1>
          <h6 id="app-moto">Like Notion, but worse.</h6>
          
        </div>
        <aside>&nbsp;</aside>
      </header>
         
        <body>
           
        <button onClick={() => login()}>Sign in with Google 🚀 </button>

        </body>
        
        </div>

  )};
  
  export default Login;