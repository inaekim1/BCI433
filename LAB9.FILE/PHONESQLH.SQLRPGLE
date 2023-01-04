000100220628        // ********************************************************************
000200220623        //  CustSu22 READ BY NATIVE LANGUAGE (ILE RPG)
000300220623        //  ContactS22 ROW RETRIEVED WITH EMBEDDED SQL
000400220623        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CustSu22 AND CONTACTW
000500190313        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000600190314
000700220628           DCL-F PHNREPORT  PRINTER OFLIND(*IN01) ;
000800220623           DCL-F CustSu22 DISK(*EXT) KEYED USAGE(*INPUT)
000900220623                 RENAME(CustSu22:CUSTR);
000901220628       // data structure for host variables from CONTACTS22
001000221120           DCL-DS CONTACTS22 EXT END-DS;
001001221120
001002220628
001003220628       // Standalone fields for indicator variables
001004220628
001005221120            DCL-S INDLCALLD  BINDEC(4:0);
001006221120            DCL-S INDNextCDate  BINDEC(4:0);
001007221120
001008221120           DCL-S Dummy  Zoned(1);
001009220628
001010220628
001300221120
001500190314        //**********************************************************************
001600190314        //*                        ***   M A I N   R O U T I N E   ***
001700190314        //**********************************************************************
001800190314
001900070119                EXSR SummaryInfo;
002000200709                WRITE NEWPAGE;
002100220623                READ CustSu22;
002200070119                DOW NOT %EOF;
002300070119                    EXSR SQLSelect;
002900190313                    IF *IN01 = *ON;
003000200709                       Write NEWPAGE;
003100190313                       *IN01 = *OFF;
003200070119                    ENDIF;
003300200709                    Write RPTLINE;
003400220623                   READ CustSu22;
003500070119                ENDDO;
003600190313                Write SUMMARY;
003700070119                *INLR = *ON;
003800070119                RETURN;
003900080923        //**********************************************************************
004000080923        //   S Q L S E L E C T   S U B R O U T I N E
004100220628        //********************************************************************
004200220628                       BEGSR    SQLSelect ;
004300220628         // A row from the Contacts table that has the same customer number as t
004400220628         // record read from the CustSu22 file is retrieved to find out the last
004500220628         // called, phone number, comments and the salesperson number.
004600220628
004700220628         //  The call back interval is added to the last date called to determin
004800220628         //  next date to call.  Since null values may be stored in the last dat
004900220628         // indicator variables are used.
005000220628           ErrorMsg = ' ';
005001220628
005002221120          EXEC SQL
005003221120              SELECT LCALLD + CALLBINT DAYS,
005004221120              LCALLD,
005005221120              PHONE,
005006221120              SlsNumber
005007221120              INTO :NextCDate :INDNextCDate,
005008221120                   :LCALLD :INDLCALLD,
005009221120                   :PHONE,
005010221120                   :SlsNumber
005011221120              FROM BCI433LIB/CONTACTS22
005012221120              WHERE CNUMBER = :CstNum;
005013221120
005014221120            SELECT;
005015221120              WHEN SQLSTATE = '00000';
005016221120              DUMMY = 0;
005017221120              WHEN SQLSTATE = '02000';
005018221120               ErrorMsg = 'MATCH NOT FOUND';
005019221120               PHONE = 9999999999;
005020221120               NextCDate = D'9999-09-09';
005021221120               LCALLD = D'9999-09-09';
005022221120               SlsNumber = -999;
005023221120              WHEN %SUBST(SQLSTATE :1:2) = '01';
005024221120               ErrorMsg = 'WARNING OCCURRED';
005025221120               PHONE = 9999999999;
005026221120               NextCDate = D'9999-09-09';
005027221120               LCALLD = D'9999-09-09';
005028221120               SlsNumber = -999;
005029221120               OTHER;
005030221120               ErrorMsg = 'ERROR OCCURRED';
005031221120               PHONE = 9999999999;
005032221120               NextCDate = D'9999-09-09';
005033221120               LCALLD = D'9999-09-09';
005034221120               SlsNumber = -999;
005035221120            ENDSL;
005036221120            IF INDLCALLD = -1;
005037221120              ErrorMsg = 'UNKNOWN DATE';
005038221120               NextCDate = D'9999-09-09';
005039221120               LCALLD = D'9999-09-09';
005040221120
005041221120            ENDIF;
009000220628           ENDSR ;
009100080923        //**********************************************************************
009200080923        // S U M M A R Y I N F O   S U B R O U T I N E
009300080923        //**********************************************************************
009400080923                         BEGSR  SummaryInfo;
009500220623
009600220623        //  D E T E R M I N E   T O T A L S   F O R   ContactS22 & CustSu22
009601220628
009602221120        EXEC SQL
009603221120        SELECT COUNT(*) INTO :CONTACTT
009604221120          FROM BCI433LIB/CONTACTS22;
009605221120
009606221120          IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
009607221120            CONTACTT = -9999;
009608221120          ENDIF;
009609221120
009610221120        EXEC SQL
009611221120        SELECT COUNT(*) INTO :CUSTOMERT
009612221120          FROM BCI433LIB/CUSTSU22;
009613221120
009614221120          IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
009615221120            CUSTOMERT = -9999;
009616221120          ENDIF;
009617221120
009618220628
011300220628        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST DATE CAL
011301220628
011302221120        EXEC SQL
011303221120        SELECT COUNT(*)
011304221120          INTO :UNKNOWNT
011305221120          FROM BCI433LIB/CONTACTS22
011306221120          WHERE LCALLD IS NULL;
011307221120
011308221120          IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
011309221120            UNKNOWNT = -99999;
011310221120          ENDIF;
011311220628
011315220628
012301221120        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  LAST DAT
012303220628
012304221120        EXEC SQL
012305221120        SELECT min(LCALLD), max(LCALLD)
012306221120          INTO :OLDESTDATE, :MOSTRECENT
012307221120          FROM BCI433LIB/CONTACTF21;
012308221120
012309221120        IF (SQLCODE <> 0) OR (SQLWN0 = '0') AND (SQLWN2 <> 'W');
012310221120          OLDESTDATE = D'9999-09-09';
012311221120          MOSTRECENT = D'9999-09-09';
012312221120        ENDIF;
012314220628
014500220628       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
014600220628       // SYSIBM/SYSDUMMY1 from System registers,Don't need check SQLCODE
014601220628
014602221120         EXEC SQL
014603221120        SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
014604221120          INTO :USER, :TIMESTAMP, :SERVER
014605221120          FROM SYSIBM/SYSDUMMY1;
014606220628
014608220628
015200220628       ENDSR;
