000100221129      //***********************************************************************
000200220628      //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE FROM 3
000300220720      //* SEPARATE TABLES, CUSTOMER2, ORDER1 AND ORDERLINE. A NUMBER IS PASSED
000400220628      //* TO THE PROGRAM TO DETERMINE WHICH RECORDS ARE INLCUDED
000500220628      //***********************************************************************
000600211111           DCL-F CUSTREPORT PRINTER OFLIND(*IN01) ;
000700211111           DCL-S OrderNumH    PACKED(5:0);
000800220628      // Declare an indicator to handle end of result set (file)
000900220628
001000221128          DCL-S EndOfFile IND;
001001221128
001100220628      // All Host Variables available under a single name
001200221128         DCL-DS OrdersRecord;
001201221128           CustName Char(31);
001202221129           OrderNum Packed(5:0);
001203221128           OrderDate Date;
001204221128           PartNum Char(4);
001205221128           Quantity Packed(3:0);
001206221128           QtPrice Packed(6:2);
001207221128           ExtPrice Packed(7:2);
001209221128         END-DS;
001300220628
001400220628
002400220628
002500220628       // LimitIn is passed to the program
002600221128
002700220628
002701221128        DCL-PI Main EXTPGM('ORDERSSQL');
002702221128          LimitIn Packed(15:5);
002703221128
002704221128        END-PI;
002800220628
002900220628
003000220628
003100220628
003200221128
003300221128       // M A I N  R O U T I N E
003400220628
003500220627                SpendLimit = LimitIn;
003600100309                EXSR PrepareFiles;
003700211111                Write ReporTitle;
003800211104                Write ColHeading;
003900100309                EXSR GetRow;
004000211203                Write NextCust;
004100211111                OrderNumH = OrderNum;
004200070202                DOW NOT EndOfFile;
004300190313                    IF *IN01 = *ON;
004400211111                        Write ReporTitle;
004500211104                        Write ColHeading;
004600190313                       *IN01 = *OFF;
004700070209                    ENDIF;
004800220628                    // Handle Control Breaks on Order Number
004900221128                 IF OrderNumH  = OrderNum;
004901221128                   WRITE OrdDetail;
004902221128                 ELSE;
004903221129                  OrderNumH = OrderNum;
004904221129                  WRITE OrdTotal;
004905221129                  TotalAll = TotalAll + TotalOrd;
004906221129                  TotalOrd = 0;
004907221129                  WRITE NextCust;
004908221129                  WRITE OrdDetail;
004910221128                 ENDIF;
006500211111                    TotalOrd = TotalOrd + ExtPrice;
006600100309                    EXSR GetRow;
006700070119                ENDDO;
006800211111                Write OrdTotal;
006900211111                TotalAll = TotalAll + TotalOrd;
007000211111                Write AllOrders;
007100070202                EXSR   WRAPUP;
007200220627                Write NotInclude;
007300070119                *INLR = *ON;
007400070119                RETURN;
007500100309        //**********************************************************************
007600100309        // O P E N F I L E S   S U B R O U T I N E
007700100309        //**********************************************************************
007800100309         BEGSR  PrepareFiles;
007900220628        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  S T R U C T U
008000220628
008100221128        EXEC SQL
008101221128         DECLARE OrdersCursor CURSOR
008300221128        FOR
008301221129         SELECT TRIM(FIRST_NAME) || ' ' || TRIM(LAST_NAME) AS CUSTNAME,
008302221129         O.ORDER_NUMBER,
008303221129         ORDER_DATE,
008304221129         PART_NUMBER,
008305221129         NUMBER_ORDERED,
008306221129         QUOTED_PRICE,
008307221129         NUMBER_ORDERED * QUOTED_PRICE
008308221128        FROM BCI433LIB/CUSTOMER2 C, BCI433LIB/ORDER1 O,
008311221128             BCI433LIB/ORDERLINE OL
008312221128        WHERE C.CUSTOMER_NUMBER = O.CUSTOMER_NUMBER AND
008313221128              O.ORDER_NUMBER = OL.ORDER_NUMBER AND
008315221129              NUMBER_ORDERED * QUOTED_PRICE > :SPENDLIMIT
008317221128        FOR READ ONLY;
010100100309
010200100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
010300221128        EXEC SQL
010400221128          OPEN ORDERSCURSOR;
010401221128         IF SQLCODE  <> 0 OR SQLWN0 = 'W';
010402221128           ENDOFFILE = *ON;
010403221128         ENDIF;
010500221128
010600220628
010700220628
010800220628
010900220628
011000220628
011100220628
011200220628
011300100309
011400221128        ENDSR;
011500100309        //**********************************************************************
011600100309        //   G E T     R O W    S U B R O U T I N E
011700100309        //**********************************************************************
011800100309            BEGSR     GETROW;
011900221128          EXEC SQL
011901221128           FETCH NEXT
011902221129             FROM OrdersCursor
011903221129             INTO :OrdersRecord;
011904221128           IF SQLCODE <> 0 OR SQLWN0 = 'W';
011905221128             ENDOFFILE = *ON;
011906221128           ENDIF;
013100100309             ENDSR;
013200100309        //**********************************************************************
013300100309        // W R A P U P     S U B R O U T I N E
013400100309        //**********************************************************************
013500100309           BEGSR WRAPUP;
013600220627
013700221128            EXEC SQL
013701221129             CLOSE   OrdersCursor;
013702221128            If SQLCODE <> 0 OR SQLWN0 = 'W';
013704221129              ENDOFFILE = *ON;
013705221128            ENDIF;
013706221129
013707221129          EXEC SQL
013708221129           SELECT COUNT(*) INTO :UNDERLIMIT
013709221129            FROM
013710221129             BCI433LIB/ORDERLINE OL
013711221129        WHERE
013713221129              NUMBER_ORDERED * QUOTED_PRICE <= :SPENDLIMIT;
015400220628
015500100309          ENDSR;
