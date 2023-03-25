// import React from "react";
// import ReactDOM from "react-dom/client";
// import { BrowserRouter, Route, Routes } from "react-router-dom";
// import "./index.css";
// import Layout from "./Layout";
// import Login from "./Login";
// import WriteBox from "./WriteBox";
// import Empty from "./Empty";
// import reportWebVitals from "./reportWebVitals";
// import { GoogleOAuthProvider } from '@react-oauth/google';
// import App from './App';

// const root = ReactDOM.createRoot(document.getElementById("root"));
// root.render(
//   <GoogleOAuthProvider clientId="261051608057-7or7frtir2qs7ffq565kcgmrrij1gcc0.apps.googleusercontent.com">
//   <React.StrictMode>
//     <Login>
//     <BrowserRouter>
//       <Routes>
//         <Switch>
//         <Route path="/login" component={Login} />
//         <Route element={<Layout />}>
//           <Route path="/" element={<Empty />} />
//           <Route path="/notes" element={<Empty />} />
//           <Route
//             path="/notes/:noteId/edit"
//             element={<WriteBox edit={true} />}
//           />
//           <Route path="/notes/:noteId" element={<WriteBox edit={false} />} />
//           {/* any other path */}
//           <Route path="*" element={<Empty />} />
//         </Route>
//         </Switch>
//       </Routes>
//     </BrowserRouter>
//     </Login>
//   </React.StrictMode>
//   </GoogleOAuthProvider>,
//   document.getElementById('root')
// );


// reportWebVitals();


// import React, { useState } from "react";
// import ReactDOM from "react-dom/client";
// import { BrowserRouter, Route, Routes } from "react-router-dom";
// import "./index.css";
// import Layout from "./Layout";
// import Login from "./Login";
// import WriteBox from "./WriteBox";
// import Empty from "./Empty";
// import reportWebVitals from "./reportWebVitals";
// import { GoogleOAuthProvider } from '@react-oauth/google';

// const root = ReactDOM.createRoot(document.getElementById("root"));

// function App() {

//   const [isAuthenticated, setIsAuthenticated] = useState(false);

//   const handleLogin = () => {
//     setIsAuthenticated(true);
//   };

//   const handleLogout = () => {
//     setIsAuthenticated(false);
//   };

//   return (
//     <GoogleOAuthProvider clientId="261051608057-7or7frtir2qs7ffq565kcgmrrij1gcc0.apps.googleusercontent.com">
//       <React.StrictMode>
//         <BrowserRouter>
//           <Routes>
//             <Route path="/login" element={<Login onLogin={handleLogin} />} />
//             {isAuthenticated ? (
//               <>
//                 <Route path="/" element={<Layout onLogout={handleLogout} />}/>
//                 <Route path="/notes" element={<Empty />} />
//                 <Route
//                   path="/notes/:noteId/edit"
//                   element={<WriteBox edit={true} onLogout={handleLogout}/>}
//                 />
//                 <Route
//                   path="/notes/:noteId"
//                   element={<WriteBox edit={false} onLogout={handleLogout}/>}
//                 />
//                 {/* any other path */}
//                 <Route path="*" element={<Empty />} />
//               </>
//             ) : (
//               <Route path="*" element={<Login onLogin={handleLogin} />} />
//             )}
//           </Routes>
//         </BrowserRouter>
//       </React.StrictMode>
//     </GoogleOAuthProvider>
//   );
//   }

// root.render(<App />, document.getElementById("root"));

// reportWebVitals();



import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import "./index.css";
import Layout from "./Layout";
import WriteBox from "./WriteBox";
import Empty from "./Empty";
import reportWebVitals from "./reportWebVitals";
import { GoogleOAuthProvider } from '@react-oauth/google';


const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <GoogleOAuthProvider clientId="672911093579-k20fo31h339ot56mem0upv1vtq8simme.apps.googleusercontent.com">
    <React.StrictMode>
      <BrowserRouter>
        <Routes>
          <Route element={<Layout />}>
            <Route path="/" element={<Empty />} />
            <Route path="/notes" element={<Empty />} />
            <Route
              path="/notes/:noteId/edit"
              element={<WriteBox edit={true} />}
            />
            <Route path="/notes/:noteId" element={<WriteBox edit={false} />} />
            {/* any other path */}
            <Route path="*" element={<Empty />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </React.StrictMode>
  </GoogleOAuthProvider>
);

reportWebVitals();



