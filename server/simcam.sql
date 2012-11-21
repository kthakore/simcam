CREATE TABLE Usrs (
        id INTEGER NOT NULL PRIMARY KEY,
        email TEXT NOT NULL,
        type VARCHAR(3) NOT NULL default 'D', /* SH Simulation and Hints, S simulation , D default */
        apikey VARCHAR(64) NOT NULL,
        current_session INTEGER NOT NULL default 0,
        json_store TEXT 
        );


CREATE TABLE Sessions (
        id INTEGER NOT NULL PRIMARY KEY,
        num INTEGER NOT NULL default 0,
        usr INTEGER,
        start_time DATETIME NOT NULL,
        end_time DATETIME NOT NULL,
        milestone INTEGER NOT NULL,
        json_store TEXT,
        FOREIGN KEY (usr) REFERENCES Usrs(id)  
        );


