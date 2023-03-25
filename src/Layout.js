//////////////////////////////////
import { useEffect, useRef, useState } from "react";
import axios from 'axios';
import { googleLogout, useGoogleLogin } from '@react-oauth/google';
import { Outlet, useNavigate, Link } from "react-router-dom";
import NoteList from "./NoteList";
import { v4 as uuidv4 } from "uuid";
import { currentDate } from "./utils";


function Layout() {
  const navigate = useNavigate();
  const mainContainerRef = useRef(null);
  const [collapse, setCollapse] = useState(false);
  const [notes, setNotes] = useState([]);
  const [editMode, setEditMode] = useState(false);
  const [currentNote, setCurrentNote] = useState(-1);
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const delete_url = "https://ppdfsk7vrqrggpkqspfch6zere0vtedy.lambda-url.ca-central-1.on.aws/"
  const save_url = "https://zqnycazvha7pjm5ecqeaf63czm0zjyvi.lambda-url.ca-central-1.on.aws/"
  const get_url = "https://ht7i4c6cjfgvgfd7xw33eocpcy0llcrm.lambda-url.ca-central-1.on.aws/"
  const login = useGoogleLogin({
    clientId: "672911093579-k20fo31h339ot56mem0upv1vtq8simme.apps.googleusercontent.com",
    onSuccess: (codeResponse) => setUser(codeResponse),
    onError: (error) => console.log('Login Failed:', error),
  });

  useEffect(() => {
    if (user) {
      axios
        .get(`https://www.googleapis.com/oauth2/v1/userinfo?access_token=${user.access_token}`, {
          headers: {
            Authorization: `Bearer ${user.access_token}`,
            Accept: 'application/json'
          },
        })
        .then((res) => {
          setProfile(res.data);
        })
        .catch((err) => console.log(err));
    }
  }, [user]);

  useEffect(() => {
    const height = mainContainerRef.current?.offsetHeight;
    if (height) {
      mainContainerRef.current.style.maxHeight = `${height}px`;
    }
  }, []);

  const logOut = () => {
    googleLogout();
    setProfile(null);
  };

  useEffect(() => {
    if (profile) {
      const saved = async() => {
        const user_email = profile.email
        const resp = await fetch(`${get_url}?email=${user_email}`)
        const notes = await resp.json()      
        return (notes)
      }
      const sNotes = async() => {
        const items = await saved();
        setNotes(items)
      }
      sNotes();
    }
  }, [profile]);

  useEffect(() => {
    if (currentNote < 0) {
      return;
    }
    if (!editMode) {
      navigate(`/notes/${currentNote + 1}`);
      return;
    }
    navigate(`/notes/${currentNote + 1}/edit`);
  }, [notes]);

  const saveNote = async (note, index) => {
    note.body = note.body.replaceAll("<p><br></p>", "");
    setNotes([...notes.slice(0,index),
    {...note},
      ...notes.slice(index+1),
    ]);
    const response = await fetch(`${save_url}`, {
      method: "POST",      
      header: {
        "Content-type": "application/json"
        },
      body: JSON.stringify({...note, "email":profile.email})
    });    
     
    try {
        const JSONresp = await response.json();
    }catch (err) {
        console.log(err);
     }

     setCurrentNote(index);
     setEditMode(true)
  };
 

  const deleteNote = async (index) => {
    const id = notes[index].id;

    setEditMode(false);
    const res = await fetch (`${delete_url}`,{
      method: "DELETE",
      headers:{
        "Content-Type": "application/json"
      },
      body: JSON.stringify(
        {id:id, "email": profile.email}
      ),
    });

    setNotes([...notes.slice(0,index),...notes.slice(index + 1)]);
    setCurrentNote(0);

    try{
      const jsonRes = await res.json();
      console.log(jsonRes);
    }catch(error){
      console.error(error)
    }
  };

  const addNote = () => {
    setNotes([
      {
        id: uuidv4(),
        title: "Untitled",
        body: "",
        when: currentDate(),
      },
      ...notes
    ])
    setEditMode(true);
    setCurrentNote(0);
    };
 

  return (
    <div id="container">
      <header>
        <aside>
          {profile && (
            <button id="menu-button" onClick={() => setCollapse(!collapse)}>
              &#9776;
            </button>
          )}
        </aside>
        <div id="app-header">
          <h1>
            <Link to="/notes">Lotion</Link>
          </h1>
          <h6 id="app-moto">Like Notion, but worse.</h6>
          </div>
          {profile ? (
            <div id = "email">
            <span>{profile.email}</span>
            <button onClick={logOut}>Log out</button>
            </div>
          ) : (
            <button onClick={() => login()} className="login-button">
              Sign in with Google
            </button>
          )}
        {!profile && <aside>&nbsp;</aside>} {/* Render aside nbsp only when the user is not logged in */}
      </header>
      {profile && (
        <div id="main-container" ref={mainContainerRef}>
          <aside id="sidebar" className={collapse ? 'hidden' : null}>
            <header>
              <div id="notes-list-heading">
                <h2>Notes</h2>
                <button id="new-note-button" onClick={addNote}>
                  +
                </button>
              </div>
            </header>
            <div id="notes-holder">
              <NoteList notes={notes} />
            </div>
          </aside>
          <div id="write-box">
            <Outlet context={[notes, saveNote, deleteNote]} />
          </div>
        </div>
      )}
    </div>
  );
}
export default Layout;
