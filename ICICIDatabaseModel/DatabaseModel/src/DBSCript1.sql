
CREATE TABLE "IC_IPG_MID_UPDATE"
   (    "IPG_IC_ID" NUMBER(10,0),
    "IPG_MID" NUMBER(10,0),
    "IPG_MOB_IC_ID" VARCHAR2(30 BYTE),
    "IPG_STATUS" NUMBER(2,0),
    "IPG_CUST_TRAN_LIMIT" VARCHAR2(10 BYTE),
    "IPG_DAILY_TRAN_LIMIT" VARCHAR2(10 BYTE),
    "IPG_REMARKS" VARCHAR2(500 BYTE),
    "IPG_RECV_DATE" DATE DEFAULT SYSDATE,
    "IPG_MOB_IC_ID_RESP" VARCHAR2(20 BYTE),
    "IPG_STATUS_RESP" VARCHAR2(20 BYTE),
    "IPG_ACTCODE_RESP" NUMBER,
    "IPG_REQ_RES_FLG" NUMBER DEFAULT 0
   ) ;

--   Data
--   ======
--   1	
--   107727	
--   123	
--   123	
--   2	
--   12	
--   12	
--   2-SUCCESS	
--   4/3/2017 7:35:47 PM		
--   false	
--   2	
--   2
  --------------------------------------

  CREATE TABLE "IC_H2H_PROP_DETAILS"
   ( "IHPD_ID" NUMBER,
    "IHPD_IC_ID" NUMBER,
    "IHPD_REQ_URL" VARCHAR2(3500 BYTE),
    "IHPD_MIS_REQ_URL" VARCHAR2(3500 BYTE),
    "IHPD_DEL_FLAG" NUMBER
   ) ; 
--Data
--=====
--1	
--107727	
--http://1.1.1.1:8080/xyd
--http://1.1.1.1:8080/xyd
--0	
--	

 -----   ---------------------------------
 CREATE TABLE "IC_MERCHANT_MASTER_TBL"
   ("ICMM_IC_ID"		NUMBER NOT NULL ENABLE,
    "ICMM_MERCHANT_CODE"	VARCHAR2(20 BYTE),
    "ICMM_MERCHANT_NAME"	VARCHAR2(80 BYTE),
    "ICMM_PAN_GIR_NUM"		VARCHAR2(25 BYTE),
    "ICMM_DEL_FLG"		NUMBER DEFAULT 0,
    "ICMM_ENTITY_CRE_FLG"	NUMBER DEFAULT 0,
    "ICMM_PG_REQUEST_FLG"	NUMBER DEFAULT 1,
    "ICMM_MID"			VARCHAR2(20 BYTE),
    "ICMM_M_DC_CHARGE"		VARCHAR2(20 BYTE),
    "ICMM_P_DC_CHARGE"		VARCHAR2(20 BYTE),
    "ICMM_DAILY_TRAN_LIMIT"	NUMBER(9,2) DEFAULT 0,
    "ICMM_CUSTOMER_TRAN_LIMIT"	NUMBER(9,2) DEFAULT 0,
    "ICMM_PG_CATEGORY"		NUMBER(1,0) DEFAULT 0,
    "ICMM_PG_MMID"		NUMBER(1,0) DEFAULT 0,
    "ICMM_EAZYPAY_MOB_IC_ID"	NUMBER(30,0),
    "ICMM_DAILY_TRAN_LIMIT_ICICI" NUMBER(9,2) DEFAULT 0,
    ); 
--Data
--=====
--107727	
--107727	
--SHANTARAM GANPAT 
--AJXPM3033B	
--0	
--2	
--1
--123123				
--0.00	
--0.00	
--0.00
--0.00
--1
--1
--107727
--0.00




----------------------------------

  CREATE OR REPLACE PROCEDURE "IC_MOBAPP_MID_UPDATE" (V_IC_ID            IN NUMBER,
                                                                 V_MID              IN VARCHAR2,
                                                                 V_MOB_IC_ID        IN NUMBER,
                                                                 V_STATUS           IN NUMBER,
                                                                 V_CUST_TRAN_LIMIT  IN VARCHAR2,
                                                                 V_DAILY_TRAN_LIMIT IN VARCHAR2,
                                                                 O_SUCCESS          OUT VARCHAR2,
                                                                 O_ERR_MSG          OUT VARCHAR2,
                                                                 O_SUCCESSDATE      OUT VARCHAR2) AS

  V_CNT NUMBER(1);

  V_IMU_CREDIT_ACCT_NO      VARCHAR2(20);
  V_IMU_MERCHANT_NAME       VARCHAR2(100);
  V_IMU_PAN_GIR_NUM         VARCHAR2(20);
  V_IMU_ACCT_OPN_DATE       DATE;
  V_IMU_EMAIL_ID            VARCHAR2(100);
  V_IMU_MOBILE_NO           VARCHAR2(15);
  V_IMU_MERCHANT_ALIAS_NAME VARCHAR2(20);
  V_IMU_MID                 NUMBER;
  V_IMU_EAZYPAY_MOB_IC_ID   NUMBER;

BEGIN
  SELECT SYSDATE INTO O_SUCCESSDATE FROM DUAL;
  SELECT COUNT(1)
    INTO V_CNT
    FROM IC_MERCHANT_MASTER_TBL
   WHERE ICMM_EAZYPAY_MOB_IC_ID = V_MOB_IC_ID
     AND ICMM_IC_ID = V_IC_ID
     AND ICMM_DEL_FLG = 0
  AND ICMM_PG_MMID = 0;
  --     and ICMM_ENTITY_CRE_FLG = 2;
  IF (V_CNT = 0) THEN
    O_SUCCESS := 'N';
    O_ERR_MSG := 'Details Mismatch / MID Already Allocated';
  ELSIF (V_CNT = 1) THEN
    ----------
    select ICMM_CREDIT_ACCT_NO,
           ICMM_MERCHANT_NAME,
           ICMM_PAN_GIR_NUM,
           ICMM_ACCT_OPN_DATE,
           ICMM_EMAIL_ID,
           ICMM_MOBILE_NO,
           ICMM_MERCHANT_ALIAS_NAME,
           ICMM_MID,
           ICMM_EAZYPAY_MOB_IC_ID
      into V_IMU_CREDIT_ACCT_NO,
           V_IMU_MERCHANT_NAME,
           V_IMU_PAN_GIR_NUM,
           V_IMU_ACCT_OPN_DATE,
           V_IMU_EMAIL_ID,
           V_IMU_MOBILE_NO,
           V_IMU_MERCHANT_ALIAS_NAME,
           V_IMU_MID,
           V_IMU_EAZYPAY_MOB_IC_ID
      from ic_merchant_master_tbl
     where icmm_ic_id = V_IC_ID
       and icmm_del_flg = 0;
    ----------

    IF (V_STATUS = 2) THEN
      -- Approve
      --update ic_merchant_master_tbl set icmm_mid=V_MID,ICMM_PG_MMID=2 where icmm_del_flg=0 and icmm_ic_id=V_IC_ID;
      INSERT INTO ic_IPG_MID_UPDATE
        (IPG_IC_ID,
         IPG_MID,
         IPG_MOB_IC_ID,
         IPG_STATUS,
         IPG_CUST_TRAN_LIMIT,
         IPG_DAILY_TRAN_LIMIT,
         IPG_REMARKS)
      VALUES
        (V_IC_ID,
         V_MID,
         V_MOB_IC_ID,
         V_STATUS,
         V_CUST_TRAN_LIMIT,
         V_DAILY_TRAN_LIMIT,
         '2' || '-SUCCESS');
      --1-IC_IPG_MID_Merchant_view share with Mobile App
      INSERT INTO IC_IPG_MID_Merchant_view
        (IIMU_IC_ID,
         IIMU_MID,
         IIMU_MOB_IC_ID,
         IIMU_STATUS,
         IIMU_CUST_TRAN_LIMIT,
         IIMU_DAILY_TRAN_LIMIT,
         IIMU_REMARKS,
         IMU_CREDIT_ACCT_NO,
         IMU_MERCHANT_NAME,
         IMU_PAN_GIR_NUM,
         IMU_ACCT_OPN_DATE,
         IMU_EMAIL_ID,
         IMU_MOBILE_NO,
         IMU_MERCHANT_ALIAS_NAME,
         IMU_MID,
         IMU_EAZYPAY_MOB_IC_ID)
      VALUES
        (V_IC_ID,
         V_MID,
         V_MOB_IC_ID,
         V_STATUS,
         V_CUST_TRAN_LIMIT,
         V_DAILY_TRAN_LIMIT,
         '2' || '-SUCCESS',
         V_IMU_CREDIT_ACCT_NO,
         V_IMU_MERCHANT_NAME,
         V_IMU_PAN_GIR_NUM,
         V_IMU_ACCT_OPN_DATE,
         V_IMU_EMAIL_ID,
         V_IMU_MOBILE_NO,
         V_IMU_MERCHANT_ALIAS_NAME,
         V_IMU_MID,
         V_IMU_EAZYPAY_MOB_IC_ID);
      --
      UPDATE IC_MERCHANT_MASTER_TBL
         SET ICMM_MID                 = V_MID,
             ICMM_PG_MMID             = 2,
             ICMM_REMARKS             = 'MID Approved-Firstdata' || sysdate,
             ICMM_CUSTOMER_TRAN_LIMIT = V_CUST_TRAN_LIMIT,
             ICMM_DAILY_TRAN_LIMIT    = V_DAILY_TRAN_LIMIT,
             ICMM_DAILY_TRAN_LIMIT_ICICI = 0
       WHERE ICMM_DEL_FLG = 0
         AND ICMM_IC_ID = V_IC_ID;
      UPDATE IC_PAYMENT_MASTER_TBL
         SET ICPM_PAYMENT_MODE = 'NB, null, DC, null, CC, null, null, null, null'
       WHERE ICPM_IC_ID = V_IC_ID
         AND ICPM_DEL_FLG = 0;
      O_SUCCESS := 'Y';
      O_ERR_MSG := 'SUCCESS';
      commit;
    ELSIF (V_STATUS = 3) THEN
      INSERT INTO ic_IPG_MID_UPDATE
        (IPG_IC_ID,
         IPG_MID,
         IPG_MOB_IC_ID,
         IPG_STATUS,
         IPG_CUST_TRAN_LIMIT,
         IPG_DAILY_TRAN_LIMIT,
         IPG_REMARKS)
      VALUES
        (V_IC_ID,
         V_MID,
         V_MOB_IC_ID,
         V_STATUS,
         V_CUST_TRAN_LIMIT,
         V_DAILY_TRAN_LIMIT,
         '1' || '-REJECT');
      --2-IC_IPG_MID_Merchant_view share with Mobile App
      INSERT INTO IC_IPG_MID_Merchant_view
        (IIMU_IC_ID,
         IIMU_MID,
         IIMU_MOB_IC_ID,
         IIMU_STATUS,
         IIMU_CUST_TRAN_LIMIT,
         IIMU_DAILY_TRAN_LIMIT,
         IIMU_REMARKS,
         IMU_CREDIT_ACCT_NO,
         IMU_MERCHANT_NAME,
         IMU_PAN_GIR_NUM,
         IMU_ACCT_OPN_DATE,
         IMU_EMAIL_ID,
         IMU_MOBILE_NO,
         IMU_MERCHANT_ALIAS_NAME,
         IMU_MID,
         IMU_EAZYPAY_MOB_IC_ID)
      VALUES
        (V_IC_ID,
         V_MID,
         V_MOB_IC_ID,
         V_STATUS,
         V_CUST_TRAN_LIMIT,
         V_DAILY_TRAN_LIMIT,
         '1' || '-REJECT',
         V_IMU_CREDIT_ACCT_NO,
         V_IMU_MERCHANT_NAME,
         V_IMU_PAN_GIR_NUM,
         V_IMU_ACCT_OPN_DATE,
         V_IMU_EMAIL_ID,
         V_IMU_MOBILE_NO,
         V_IMU_MERCHANT_ALIAS_NAME,
         V_IMU_MID,
         V_IMU_EAZYPAY_MOB_IC_ID);
      --
      -- REJECT
      UPDATE IC_MERCHANT_MASTER_TBL
         SET ICMM_PG_MMID = 3,
             ICMM_REMARKS = 'MID Rejected-Firstdata' || sysdate
       WHERE ICMM_DEL_FLG = 0
         AND ICMM_IC_ID = V_IC_ID;
      UPDATE IC_PAYMENT_MASTER_TBL
         SET ICPM_PAYMENT_MODE = 'NB, null, null, null, null, null, null, null, null'
       WHERE ICPM_IC_ID = V_IC_ID
         AND ICPM_DEL_FLG = 0;
      O_SUCCESS := 'Y';
      O_ERR_MSG := 'REJECTED';
      COMMIT;
    END IF;
  ELSE
    INSERT INTO ic_IPG_MID_UPDATE
      (IPG_IC_ID,
       IPG_MID,
       IPG_MOB_IC_ID,
       IPG_STATUS,
       IPG_CUST_TRAN_LIMIT,
       IPG_DAILY_TRAN_LIMIT,
       IPG_REMARKS)
    VALUES
      (V_IC_ID,
       V_MID,
       V_MOB_IC_ID,
       V_STATUS,
       V_CUST_TRAN_LIMIT,
       V_DAILY_TRAN_LIMIT,
       '9' || '-N-Merchnat Deatils Issues, Pls contact IBANK');
    --3-IC_IPG_MID_Merchant_view share with Mobile App
    INSERT INTO IC_IPG_MID_Merchant_view
      (IIMU_IC_ID,
       IIMU_MID,
       IIMU_MOB_IC_ID,
       IIMU_STATUS,
       IIMU_CUST_TRAN_LIMIT,
       IIMU_DAILY_TRAN_LIMIT,
       IIMU_REMARKS,
       IMU_CREDIT_ACCT_NO,
       IMU_MERCHANT_NAME,
       IMU_PAN_GIR_NUM,
       IMU_ACCT_OPN_DATE,
       IMU_EMAIL_ID,
       IMU_MOBILE_NO,
       IMU_MERCHANT_ALIAS_NAME,
       IMU_MID,
       IMU_EAZYPAY_MOB_IC_ID)
    VALUES
      (V_IC_ID,
       V_MID,
       V_MOB_IC_ID,
       V_STATUS,
       V_CUST_TRAN_LIMIT,
       V_DAILY_TRAN_LIMIT,
       '9' || '-N-Merchnat Deatils Issues, Pls contact IBANK1',
       V_IMU_CREDIT_ACCT_NO,
       V_IMU_MERCHANT_NAME,
       V_IMU_PAN_GIR_NUM,
       V_IMU_ACCT_OPN_DATE,
       V_IMU_EMAIL_ID,
       V_IMU_MOBILE_NO,
       V_IMU_MERCHANT_ALIAS_NAME,
       V_IMU_MID,
       V_IMU_EAZYPAY_MOB_IC_ID);
    --
    O_SUCCESS := 'N';
    O_ERR_MSG := 'Merchnat Deatils Issues, Pls contact IBANK2';
    COMMIT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    O_SUCCESS := 'N';
    O_ERR_MSG := 'Merchnat Deatils Issues, Pls contact IBANK3';
END IC_MOBAPP_MID_UPDATE;









/