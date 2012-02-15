input metauml;

beginfig(1);
    Actor.U("User");
    U.nw=(0,0);
    drawObject(U);
    Actor.S("Student");
    S.nw=(-50, -75);
    drawObject(S);
    Actor.T("Trainer");
    T.nw=( 50, -75 );
    drawObject(T);
    Actor.R("Researcher");
    R.nw= ( -57, -150 );
    drawObject(R);
    

    link(inheritance)(S.n -- U.s);
    link(inheritance)(T.n -- U.s);
    link(inheritance)(R.n -- S.s);

endfig;


end
