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
    Usecase.cal("Calibration");
    Usecase.sao("Select an Origin");
    Usecase.ald("Adjust Lens", "Distortion");
    Usecase.sg("Select grid");
    Usecase.pg("Place grid");
    Usecase.srwp("Select Real", "World Point");
    Usecase.ac("Accuracy", "Comparison");
 
    MC.e = U.w + (150, 0); 
    NC.e = MC.w + (150, 50 );
    ecm.e = MC.w + (200, 0 );
    enf.e = ecm.w + (200, 0 );
    eaof.n = ecm.s + (0, -30 );
    ear.w = eaof.e + (70, 0 );
    cal.ne = MC.s + (100, -140 );
    sao.s = cal.n + (0, 30 );
    ald.e = cal.w + (-100, 0 );
    srwp.n = cal.s + (0, -40 );
    ac.n = srwp.s + (0,-40);
    sg.w = cal.e + (100,0 );
    pg.w = sg.e + (100,0 );
   

    drawObject(U);
    drawObject(MC);
    drawObject(NC);
    drawObject(ecm);
    drawObject(enf);
    drawObject(eaof);
    drawObject(ear); 
    drawObject(cal);
    drawObject(sao);
    drawObject(ald);
    drawObject(sg);
    drawObject(pg);
    drawObject(srwp);
    drawObject(ac);
    

    link(association)(U.e -- MC.w );
    link(dependency)(MC.e -- NC.w );
    link(dependency)(MC.e -- ecm.w);
    link(dependency)(ecm.e -- enf.w);
    link(dependency)(ecm.s -- eaof.n);
    link(dependency)(ecm.s -- ear.n);
    link(dependency)(MC.s -- (cal.w + (5, 10)));
    link(dependency)(cal.n -- sao.s);
    link(dependency)(cal.w -- ald.e);
    link(dependency)(cal.s -- srwp.n);
    link(dependency)(srwp.s -- ac.n );
    link(dependency)(cal.e -- sg.w);
    link(dependency)( (sg.e + (0, 5) ) -- (pg.w + (0, 5) ) );
    link(dependency)( (pg.w + (0, -5) ) -- (sg.e + (0, -5) ) );

    



endfig;


end
