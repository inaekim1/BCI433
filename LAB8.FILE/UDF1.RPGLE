000100221205       DCL-Proc CalcRate Export;
000101221205         Dcl-Pi *N Zoned(3:2);
000102221205           HPrice Packed(3);
000103221205         END-PI;
000104221205
000105221205       DCL-S Tax Zoned(3:2);
000106221205
000107221205        SELECT;
000108221205           When FirstTime = 'Y';
000109221205             LandTax = 0;
000110221205           When HPrice > 2000000;
000111221205             EVAL(H) LandTax = HPrice * .025;
000112221205           When HPrice > 399999;
000113221205             EVAL(H) LandTax = HPrice * .02;
000114221205           When HPrice > 249999;
000115221205             EVAL(H) LandTax = HPrice * .015;
000116221205           When HPrice > 54999;
000117221205             EVAL(H) LandTax = HPrice * .01;
000118221205           Other;
000119221205             EVAL(H) LandTax = HPrice * .005;
000120221205         ENDSL;
000121221205
000122221205       END-PROC;
