MERGE INTO "PROD_DATA_WAREHOUSE"."MAIN"."FACT_CUSTOMER_PRODUCT_PRICE" 
USING 
    (
    SELECT ROUND(TO_CHAR(CURRENT_TIMESTAMP(),'YYYYMMDD'))::DOUBLE AS DATE_KEY,
           
        (CASE 
             WHEN t15.CUSTOMER_KEY IS NULL
             THEN -1
         ELSE t15.CUSTOMER_KEY
         END) AS CUSTOMER_KEY,
           
        (CASE 
             WHEN t15.PRODUCT_KEY IS NULL
             THEN -1
         ELSE t15.PRODUCT_KEY
         END) AS PRODUCT_KEY,
           
        (CASE 
             WHEN t15.CURRENCY_KEY IS NULL
             THEN -1
         ELSE t15.CURRENCY_KEY
         END) AS LOCAL_CURRENCY_KEY,
           
        (CASE 
             WHEN DIM1.PRICE_LEVEL_KEY IS NULL
             THEN -1
         ELSE DIM1.PRICE_LEVEL_KEY
         END) AS PRICE_LEVEL_KEY,
           
        (CASE t15.ASSIGNEDPRICELEVEL
             WHEN 'T'
             THEN 'TRUE'
             WHEN 'F'
             THEN 'FALSE'
         ELSE 'FALSE'
         END)::VARCHAR(7) AS PRICE_LEVEL_ASSIGNED_INDICATOR,
           (t15.QUANTITY::NUMBER(19,0))::DOUBLE AS QUANTITY_COUNT,
           (t15.SALEUNIT::NUMBER(19,0))::DOUBLE AS SALE_UNIT_COUNT,
           t15.UNITPRICE::NUMBER(28,2) AS LOCAL_CURRENCY_UNIT_PRICE_AMOUNT,
           t15._FIVETRAN_SYNCED AS SOURCE_EXTRACT_DATETIME,
           CURRENT_TIMESTAMP() AS LAST_MODIFIED_DATETIME

        FROM 
        (
            SELECT 
                DIM0."PRICE_LEVEL_KEY"::DOUBLE,
                DIM0."PRICE_LEVEL_ID"::DOUBLE
            FROM "PROD_DATA_WAREHOUSE"."MAIN"."DIM_PRICE_LEVEL"
        ) AS DIM1
        RIGHT JOIN 
        (
            SELECT 
                DIM3.CURRENCY_KEY,
                t13.PRODUCT_KEY,
                t13.CUSTOMER_KEY,
                t13.ASSIGNEDPRICELEVEL,
                t13.PRICELEVEL,
                t13.QUANTITY,
                t13.SALEUNIT,
                t13.UNITPRICE,
                t13._FIVETRAN_SYNCED
            FROM 
            (
                SELECT 
                    DIM2."CURRENCY_KEY"::DOUBLE,
                    DIM2."NETSUITE_CURRENCY_ID"::DOUBLE
                FROM "PROD_DATA_WAREHOUSE"."MAIN"."DIM_CURRENCY"
            ) AS DIM3
            RIGHT JOIN 
            (
                SELECT 
                    DIM4.PRODUCT_KEY,
                    t11.CUSTOMER_KEY,
                    t11.ASSIGNEDPRICELEVEL,
                    t11.CURRENCY,
                    t11.PRICELEVEL,
                    t11.QUANTITY,
                    t11.SALEUNIT,
                    t11.UNITPRICE,
                    t11._FIVETRAN_SYNCED
                FROM 
                (
                    SELECT 
                        DIM4."PRODUCT_KEY"::DOUBLE,
                        DIM4."NETSUITE_PRODUCT_ID"::DOUBLE
                    FROM "PROD_DATA_WAREHOUSE"."MAIN"."DIM_PRODUCT"
                ) AS DIM5
                RIGHT JOIN 
                (
                    SELECT 
                        DIM6.CUSTOMER_KEY,
                        PRI1.ASSIGNEDPRICELEVEL,
                        PRI1.CURRENCY,
                        PRI1.ITEM,
                        PRI1.PRICELEVEL,
                        PRI1.QUANTITY,
                        PRI1.SALEUNIT,
                        PRI1.UNITPRICE,
                        PRI1._FIVETRAN_SYNCED
                    FROM 
                    (
                        SELECT 
                            DIM6."CUSTOMER_KEY"::DOUBLE,
                            DIM6."NETSUITE_CUSTOMER_ID"::DOUBLE
                        FROM "PROD_DATA_WAREHOUSE"."MAIN"."DIM_CUSTOMER"
                    )AS DIM6
                    RIGHT JOIN 
                    (
                        SELECT 
                            PRI0."ASSIGNEDPRICELEVEL",
                            PRI0."CURRENCY"::DOUBLE,
                            PRI0."CUSTOMER"::DOUBLE,
                            PRI0."ITEM"::DOUBLE,
                            PRI0."PRICELEVEL"::DOUBLE,
                            PRI0."QUANTITY"::DOUBLE,
                            PRI0."SALEUNIT"::DOUBLE,
                            PRI0."UNITPRICE",
                            (PRI0."_FIVETRAN_SYNCED"::TIMESTAMPNTZ)::TIMESTAMPNTZ
                        FROM "PROD_LAKE_NETSUITE"."NETSUITE_SUITEANALYTICS_REIMPORT"."PRICINGWITHCUSTOMERS" AS PRI0
                    )AS PRI1
                    ON PRI0.CUSTOMER = DIM6.NETSUITE_CUSTOMER_ID
                ) AS t11
                ON t11.ITEM = DIM5.NETSUITE_PRODUCT_ID
            ) AS t13
            ON t13.CURRENCY = DIM3.NETSUITE_CURRENCY_ID
        ) AS t15
        ON t15.PRICELEVEL = DIM1.PRICE_LEVEL_ID
    ) AS t17

ON ((((("FACT_CUSTOMER_PRODUCT_PRICE"."DATE_KEY"::DOUBLE) = t17.DATE_KEY) 
AND (("FACT_CUSTOMER_PRODUCT_PRICE"."CUSTOMER_KEY"::DOUBLE) = t17.CUSTOMER_KEY)) 
AND (("FACT_CUSTOMER_PRODUCT_PRICE"."PRODUCT_KEY"::DOUBLE) = t17.PRODUCT_KEY)) 
AND (("FACT_CUSTOMER_PRODUCT_PRICE"."LOCAL_CURRENCY_KEY"::DOUBLE) = t17.LOCAL_CURRENCY_KEY))
AND (("FACT_CUSTOMER_PRODUCT_PRICE"."PRICE_LEVEL_KEY"::DOUBLE) = t17.PRICE_LEVEL_KEY) 
AND NOT (0 = 
    (CASE 1
         WHEN 1
         THEN 1
         WHEN 2
         THEN 2
         WHEN 3
         THEN 3
     ELSE 0
     END)) 
WHEN MATCHED 
AND 1 = 1 THEN
 UPDATE SET "FACT_CUSTOMER_PRODUCT_PRICE"."PRICE_LEVEL_ASSIGNED_INDICATOR" = t17.PRICE_LEVEL_ASSIGNED_INDICATOR, "FACT_CUSTOMER_PRODUCT_PRICE"."QUANTITY_COUNT" = t17.QUANTITY_COUNT, "FACT_CUSTOMER_PRODUCT_PRICE"."SALE_UNIT_COUNT" = t17.SALE_UNIT_COUNT, "FACT_CUSTOMER_PRODUCT_PRICE"."LOCAL_CURRENCY_UNIT_PRICE_AMOUNT" = t17.LOCAL_CURRENCY_UNIT_PRICE_AMOUNT, "FACT_CUSTOMER_PRODUCT_PRICE"."SOURCE_EXTRACT_DATETIME" = t17.SOURCE_EXTRACT_DATETIME, "FACT_CUSTOMER_PRODUCT_PRICE"."LAST_MODIFIED_DATETIME" = t17.LAST_MODIFIED_DATETIME 
WHEN NOT MATCHED THEN
 INSERT("DATE_KEY","CUSTOMER_KEY","PRODUCT_KEY","LOCAL_CURRENCY_KEY","PRICE_LEVEL_KEY","PRICE_LEVEL_ASSIGNED_INDICATOR","QUANTITY_COUNT","SALE_UNIT_COUNT","LOCAL_CURRENCY_UNIT_PRICE_AMOUNT","SOURCE_EXTRACT_DATETIME","LAST_MODIFIED_DATETIME") 
VALUES(t17.DATE_KEY,
           t17.CUSTOMER_KEY,
           t17.PRODUCT_KEY,
           t17.LOCAL_CURRENCY_KEY,
           t17.PRICE_LEVEL_KEY,
           t17.PRICE_LEVEL_ASSIGNED_INDICATOR,
           t17.QUANTITY_COUNT,
           t17.SALE_UNIT_COUNT,
           t17.LOCAL_CURRENCY_UNIT_PRICE_AMOUNT,
           t17.SOURCE_EXTRACT_DATETIME,
           t17.LAST_MODIFIED_DATETIME)