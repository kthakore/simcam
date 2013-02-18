CREATE TABLE Usrs (
        id INTEGER NOT NULL PRIMARY KEY,
        email TEXT NOT NULL,
        type VARCHAR(3) NOT NULL default 'D', /* SH Simulation and Hints, S simulation , D default */
        current_session INTEGER NOT NULL default 0,
        json_store TEXT,
	study VARCHAR(3) NOT NULL default 'CV' /* CV content validity, TP three prong study */
	 
        );


CREATE TABLE Sessions (
        id INTEGER NOT NULL PRIMARY KEY,
        usr INTEGER,
        start_time DATETIME NOT NULL,
        end_time DATETIME,
        milestone INTEGER NOT NULL default 0,
        json_store TEXT,
        FOREIGN KEY (usr) REFERENCES Usrs(id)  
        );

/*
{"fov":35,"r3":0,"t1":"1","r_z":0,"far":10000,"u":400,"t2":0,"alpha":"0.01","p_z":15,"r1":"2","success":1,"out":"job_images\/9609a29f0358ebad3825a9bfbb30a2880f101046.png","job_id":"9609a29f0358ebad3825a9bfbb30a2880f101046","final_image":"job_images\/9609a29f0358ebad3825a9bfbb30a2880f101046.png","p_y":0,"v":320,"image":"","near":0.4,"ar":1.25,"p_x":0,"r_y":0,"r2":"2","r_x":0}
*/

CREATE TABLE Camera (
        id INTEGER NOT NULL PRIMARY KEY,
        alpha REAL,
        near REAL,
        far REAL,
        final_image TEXT,
        fov REAL,
        image TEXT,
        job_id INTEGER, 
        p_x REAL,
        p_y REAL,
        p_z REAL,
        r1 REAL,
        r2 REAL,
        r3 REAL,
        r_x REAL,
        r_y REAL,
        r_z REAL,
        success INTEGER,
        t1 REAL,
        t2 REAL,
        u  REAL,
        v REAL
);

insert into Camera values (0,0.0,0.4,10000.0,'job_images/a63b500296abc9594c0a183b9292c7c5c243cdff.png',35.0,'job_images/a63b500296abc9594c0a183b9292c7c5c243cdff.png','a63b500296abc9594c0a183b9292c7c5c243cdff','','',15.0,'','','','','','',1,'','',400.0,320.0);

CREATE TABLE Versions (
    code FLOAT,
    created DATETIME
);

insert into Versions values ( 0.001, datetime('now') );
