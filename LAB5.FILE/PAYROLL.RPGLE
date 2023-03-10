000101221029
000102221029         DCL-F SHIFTWEEK KEYED USAGE(*INPUT) RENAME(SHIFTWEEK:SHIFTWEEKR);
000103221029         DCL-F SHIFTRATES DISK USAGE(*INPUT) RENAME(SHIFTRATES:SHIFTRATER);
000104221029
000105221029
000106221029         DCL-F PAYPRTF PRINTER OFLIND(*IN01);
000107221029         DCL-F PAYSUMMARY WORKSTN;
000108221029
000109221029         DCL-S HOURSOVER PACKED(3);
000110221029
000111221029                        READ SHIFTRATES;
000112221029                        WRITE TITLE;
000113221029                        WRITE COLHDG;
000114221029                        READ SHIFTWEEK;
000115221029
000116221029                        DOW NOT %EOF(SHIFTWEEK);
000117221029                        EXSR PAYSR;
000118221029                        IF *IN01;
000119221029                        WRITE TITLE;
000120221029                        WRITE COLHDG;
000121221029                        *IN01 = *OFF;
000122221029                        ENDIF;
000123221029                        WRITE EMPDETAIL;
000124221029                        READ SHIFTWEEK;
000125221029                        ENDDO;
000126221029
000127221029                        TOTWKPAY = TOTREGPAY + TOTOVTPAY;
000128221029                        WRITE TOTALS;
000129221029                        EXFMT RECORD1;
000130221029                        *INLR = *ON;
000131221029                        RETURN;
000132221029
000133221029       BEGSR PAYSR;
000134221029                        SELECT;
000135221029                        WHEN WORKSHIFT = '1';
000136221029                          HOURLYRATE = DAYHRS;
000137221029                        WHEN WORKSHIFT = '2';
000138221029                          HOURLYRATE = AFTHRS;
000139221029                        WHEN WORKSHIFT = '3';
000140221029                          HOURLYRATE = NIGHTHRS;
000141221029                        ENDSL;
000142221029
000143221029                        SELECT;
000144221029                        WHEN PAYCLASS =  1 ;
000145221029                          EVAL(H) HOURLYRATE = HOURLYRATE * 1.094;
000146221029                        WHEN PAYCLASS =  2 ;
000147221029                          EVAL(H) HOURLYRATE = HOURLYRATE * 1.062;
000148221029                        WHEN PAYCLASS =  3 ;
000149221029                          EVAL(H) HOURLYRATE = HOURLYRATE * 0.957;
000150221029                        ENDSL;
000151221029
000152221029                        HOURSOVER = HRSWORKED - 40;
000153221029
000154221029                        SELECT;
000155221029                        WHEN HOURSOVER > 0;
000156221029                          EVAL(H) OVERPAY = HOURLYRATE * 1.5 * HOURSOVER;
000157221029                          EVAL REGULARPAY = 40 * HOURLYRATE;
000158221029                 OTHER;
000159221029                          EVAL REGULARPAY = HRSWORKED * HOURLYRATE;
000160221029                          OVERPAY = 0;
000161221029                        ENDSL;
000162221029
000163221029                        WEEKLYPAY = REGULARPAY + OVERPAY;
000164221029
000165221029                        TOTREGPAY = TOTREGPAY + REGULARPAY;
000166221029                        TOTOVTPAY = TOTOVTPAY + OVERPAY;
000167221029       ENDSR;
000168221029
000169221029
