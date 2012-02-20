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

beginfig(2);

    Usecase.MC("Make Camera");
       
    Usecase.NC("Name Camera");
    Usecase.ecm("Enter Camera",  "Measurements");
    Usecase.enf("Enter Near and", "Far Z Values");
    Usecase.eaof("Enter Angle", "of Frustrum" );
    Usecase.ear("Enter Aspect", "Ratio");
 
    MC.e = U.w + (150, 0); 
    NC.e = MC.w + (150, 50 );
    ecm.e = MC.w + (200, 0 );
    enf.e = ecm.w + (200, 0 );
    eaof.n = ecm.s + (0, -30 );
    ear.w = eaof.e + (70, 0 );
   

    drawObject(U);
    drawObject(MC);
    drawObject(NC);
    drawObject(ecm);
    drawObject(enf);
    drawObject(eaof);
    drawObject(ear); 

    link(association)(U.e -- MC.w );
    link(dependency)(MC.e -- NC.w );
    link(dependency)(MC.e -- ecm.w);
    link(dependency)(ecm.e -- enf.w);
    link(dependency)(ecm.s -- eaof.n);
    link(dependency)(ecm.s -- ear.n);
    



endfig;


end
