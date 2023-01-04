000100221205         DCL-F RESTATEDS2  Workstn;
000101221205         DCL-PI Main extPgm('REALESTATE');
000102221205
000103221205         END-PI;
000104221205
000105221205         /COPY LAB8,PROTO
000106221205
000107221205         EXSR CLEAR;
000108221005         EXFMT SaleInfo;
000109221005         DOW NOT(*IN03);
000110221005            SELECT;
000111221005              WHEN HOUSEPRICE = 0;
000112221005               *IN81 = *ON;
000113221005              EXFMT SALEINFO;
000114221005               *IN81 = *OFF;
000115221005              ITER;
000116221005              WHEN PRESIDENCE = '';
000117221005               *IN82 = *ON;
000118221005              EXFMT SALEINFO;
000119221005               *IN82 = *OFF;
000120221005              ITER;
000121221005             WHEN FIRSTTIME = '';
000122221005              *IN83 = *ON;
000123221005             EXFMT SALEINFO;
000124221005              *IN83 = *OFF;
000125221005             ITER;
000126221005             WHEN *IN06;
000127221005              LEGALFEES = 900;
000128221005              SURVEYFEE = 850;
000129221005              TITLEINS = 265;
000130221005              INSPECTION = 425;
000131221005             EXFMT SALEINFO;
000132221005             ITER;
000133221005
000134221005            OTHER;
000135221005             EXSR BUYERSR;
000136221005             EXSR SELLERSR;
000137221005             *IN79 = *ON;
000139221005             WRITE SaleInfo;
000143221005             EXFMT Result;
000144221005             *IN79 = *OFF;
000145221005            ENDSL;
000146221005           IF *IN03 = *OFF;
000147221005             EXSR CLEAR;
000148221005             EXFMT SaleInfo;
000149221005           ENDIF;
000150221005         ENDDO;
000151221005
000152221005       *INLR = *ON;
000153221005            RETURN;
000154221005       BEGSR CLEAR;
000155221005         LegalFees = 0;
000156221005         SurveyFee = 0;
000157221005         TitleIns = 0;
000158221005         Inspection = 0;
000159221005         HousePrice = 0;
000160221205         PResidence = '';
000161221205         FirstTime = '';
000162221005         AgentRate = 5;
000163221005         totalcosts = 0;
000164221205         CostMsg = '';
000165221005       ENDSR;
000166221005       BEGSR BuyerSr;
000167221005         TotalCosts = LegalFees + SurveyFee + TitleIns + Inspection;
000168221005         If TotalCosts < 1001;
000169221205           CostMsg = 'UNREALISTIC COSTS SUPPLIED';
000170221005           *IN99 = *ON;
000171221005           ELSE;
000172221005             *IN99 = *OFF;
000173221005         ENDIF;
000174221205           If FirstTime = 'Y';
000175221005             LandTax = 0;
000176221205           Else;
000177221205             LandTax = CalcTax(HousePrice);
000178221205           ENDIF;
000186221005         BuyerPays = HousePrice + LandTax + TotalCosts;
000187221005       ENDSR;
000188221005
000189221005       BEGSR SellerSR;
000190221005         Commission = AgentRate/100 * HousePrice;
000191221005         If PResidence = 'Y';
000192221005           SellerNets = HousePrice - Commission;
000193221005         Else;
000194221005           EVAL(H) CapitalGns = (HousePrice * .5) * .07;
000195221005           SellerNets = HousePrice - (Commission + CapitalGns);
000196221005         ENDIF;
000197221005       ENDSR;
000198221005
