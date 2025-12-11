-- Monthly Goal Achievement Query for 2025
-- Shows cumulative excess over YTD goal for each calendar month

WITH BaseLineItems AS (
    -- Get line items with LTM calculation (Product Category level)
    SELECT
        line.Id,
        line.OpportunityId,
        line.Business_Plan_Level__c,
        line.Product_Category__c,
        line.Key_Initiative__c,
        line.Key_Initiative_Year__c,
        opp.Actual_Close_Date__c,
        cus.Customer,
        cus.Salesperson,
        cus.Area,
        cus.ShortName,
        line.Product_Description__c,
        SUM(CAST(CASE
            WHEN sls.InvoiceDate BETWEEN DATEADD(yy, -1, opp.Actual_Close_Date__c) AND opp.Actual_Close_Date__c
            THEN sls.NetSalesValue
            ELSE 0
        END AS FLOAT)) AS LTM_At_Capture__c
    FROM Opportunity AS opp
    INNER JOIN RecordTypes AS rec ON opp.RecordTypeId = rec.RecordTypeId
    INNER JOIN OpportunityLineItem AS line ON opp.Id = line.OpportunityId
    INNER JOIN SysproCompany1.dbo.ArCustomer AS cus WITH(READPAST)
        ON opp.Account_Customer_ID__c COLLATE Latin1_General_BIN = cus.Customer
    INNER JOIN sales_Transactions AS sls WITH(READPAST)
        ON line.Product_Category__c COLLATE Latin1_General_BIN = sls.ProductClass
        AND cus.ShortName = sls.ShortName
    WHERE (opp.RecordTypeId = '012G0000000jBimIAE'
        OR (opp.IsClosed = 'true' AND opp.IsWon = 'true' AND opp.IsDeleted = 'false'
            AND rec.RecordType IN ('Business Plan', 'Growth Plan')))
    AND ((line.Business_Plan_Level__c = N'Branch' AND cus.Customer = sls.Customer) OR
         (line.Business_Plan_Level__c = N'Salesperson' AND cus.Salesperson = sls.Salesperson) OR
         (line.Business_Plan_Level__c = N'Region' AND cus.Area = sls.Area))
    AND line.Product_Description__c IS NULL
    GROUP BY line.Id, line.OpportunityId, line.Business_Plan_Level__c, line.Product_Category__c,
             line.Key_Initiative__c, line.Key_Initiative_Year__c, opp.Actual_Close_Date__c,
             cus.Customer, cus.Salesperson, cus.Area, cus.ShortName, line.Product_Description__c

    UNION ALL

    -- Get line items with LTM calculation (SKU level)
    SELECT
        line.Id,
        line.OpportunityId,
        line.Business_Plan_Level__c,
        line.Product_Category__c,
        line.Key_Initiative__c,
        line.Key_Initiative_Year__c,
        opp.Actual_Close_Date__c,
        cus.Customer,
        cus.Salesperson,
        cus.Area,
        cus.ShortName,
        line.Product_Description__c,
        SUM(CAST(CASE
            WHEN sls.InvoiceDate BETWEEN DATEADD(yy, -1, opp.Actual_Close_Date__c) AND opp.Actual_Close_Date__c
            THEN sls.NetSalesValue
            ELSE 0
        END AS FLOAT)) AS LTM_At_Capture__c
    FROM Opportunity AS opp
    INNER JOIN RecordTypes AS rec ON opp.RecordTypeId = rec.RecordTypeId
    INNER JOIN OpportunityLineItem AS line ON opp.Id = line.OpportunityId
    INNER JOIN SysproCompany1.dbo.ArCustomer AS cus WITH(READPAST)
        ON opp.Account_Customer_ID__c COLLATE Latin1_General_BIN = cus.Customer
    INNER JOIN sales_Transactions AS sls WITH(READPAST)
        ON line.Product_Description__c COLLATE Latin1_General_BIN = sls.StockCode
        AND cus.ShortName = sls.ShortName
    WHERE (opp.RecordTypeId = '012G0000000jBimIAE'
        OR (opp.IsClosed = 'true' AND opp.IsWon = 'true' AND opp.IsDeleted = 'false'
            AND rec.RecordType IN ('Business Plan', 'Growth Plan')))
    AND ((line.Business_Plan_Level__c = N'Branch' AND cus.Customer = sls.Customer) OR
         (line.Business_Plan_Level__c = N'Salesperson' AND cus.Salesperson = sls.Salesperson) OR
         (line.Business_Plan_Level__c = N'Region' AND cus.Area = sls.Area))
    AND line.Product_Description__c IS NOT NULL
    GROUP BY line.Id, line.OpportunityId, line.Business_Plan_Level__c, line.Product_Category__c,
             line.Key_Initiative__c, line.Key_Initiative_Year__c, opp.Actual_Close_Date__c,
             cus.Customer, cus.Salesperson, cus.Area, cus.ShortName, line.Product_Description__c
),
SalesData2025 AS (
    -- Get 2025 sales transactions after close date (Product Category level)
    SELECT
        line.Id,
        sls.InvoiceDate,
        sls.NetSalesValue
    FROM Opportunity AS opp
    INNER JOIN RecordTypes AS rec ON opp.RecordTypeId = rec.RecordTypeId
    INNER JOIN OpportunityLineItem AS line ON opp.Id = line.OpportunityId
    INNER JOIN SysproCompany1.dbo.ArCustomer AS cus WITH(READPAST)
        ON opp.Account_Customer_ID__c COLLATE Latin1_General_BIN = cus.Customer
    INNER JOIN sales_Transactions AS sls WITH(READPAST)
        ON line.Product_Category__c COLLATE Latin1_General_BIN = sls.ProductClass
        AND cus.ShortName = sls.ShortName
    WHERE (opp.RecordTypeId = '012G0000000jBimIAE'
        OR (opp.IsClosed = 'true' AND opp.IsWon = 'true' AND opp.IsDeleted = 'false'
            AND rec.RecordType IN ('Business Plan', 'Growth Plan')))
    AND ((line.Business_Plan_Level__c = N'Branch' AND cus.Customer = sls.Customer) OR
         (line.Business_Plan_Level__c = N'Salesperson' AND cus.Salesperson = sls.Salesperson) OR
         (line.Business_Plan_Level__c = N'Region' AND cus.Area = sls.Area))
    AND line.Product_Description__c IS NULL
    AND sls.InvoiceDate >= opp.Actual_Close_Date__c
    AND sls.InvoiceDate >= '2025-01-01'

    UNION ALL

    -- Get 2025 sales transactions after close date (SKU level)
    SELECT
        line.Id,
        sls.InvoiceDate,
        sls.NetSalesValue
    FROM Opportunity AS opp
    INNER JOIN RecordTypes AS rec ON opp.RecordTypeId = rec.RecordTypeId
    INNER JOIN OpportunityLineItem AS line ON opp.Id = line.OpportunityId
    INNER JOIN SysproCompany1.dbo.ArCustomer AS cus WITH(READPAST)
        ON opp.Account_Customer_ID__c COLLATE Latin1_General_BIN = cus.Customer
    INNER JOIN sales_Transactions AS sls WITH(READPAST)
        ON line.Product_Description__c COLLATE Latin1_General_BIN = sls.StockCode
        AND cus.ShortName = sls.ShortName
    WHERE (opp.RecordTypeId = '012G0000000jBimIAE'
        OR (opp.IsClosed = 'true' AND opp.IsWon = 'true' AND opp.IsDeleted = 'false'
            AND rec.RecordType IN ('Business Plan', 'Growth Plan')))
    AND ((line.Business_Plan_Level__c = N'Branch' AND cus.Customer = sls.Customer) OR
         (line.Business_Plan_Level__c = N'Salesperson' AND cus.Salesperson = sls.Salesperson) OR
         (line.Business_Plan_Level__c = N'Region' AND cus.Area = sls.Area))
    AND line.Product_Description__c IS NOT NULL
    AND sls.InvoiceDate >= opp.Actual_Close_Date__c
    AND sls.InvoiceDate >= '2025-01-01'
),
AggregatedBase AS (
    -- Aggregate LTM by line item
    SELECT
        Id,
        OpportunityId,
        Business_Plan_Level__c,
        Product_Category__c,
        Key_Initiative__c,
        Key_Initiative_Year__c,
        Actual_Close_Date__c,
        SUM(LTM_At_Capture__c) AS LTM_At_Capture__c
    FROM BaseLineItems
    GROUP BY Id, OpportunityId, Business_Plan_Level__c, Product_Category__c,
             Key_Initiative__c, Key_Initiative_Year__c, Actual_Close_Date__c
)
SELECT
    ab.Id,
    ab.OpportunityId,
    ab.Business_Plan_Level__c,
    ab.Product_Category__c,
    ab.Key_Initiative__c,
    ab.Key_Initiative_Year__c,

    -- January 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-01-31' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-01-31')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-01-31' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-01-31'))
        ELSE 0
    END AS Jan,

    -- February 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-02-28' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-02-28')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-02-28' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-02-28'))
        ELSE 0
    END AS Feb,

    -- March 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-03-31' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-03-31')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-03-31' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-03-31'))
        ELSE 0
    END AS Mar,

    -- April 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-04-30' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-04-30')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-04-30' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-04-30'))
        ELSE 0
    END AS Apr,

    -- May 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-05-31' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-05-31')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-05-31' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-05-31'))
        ELSE 0
    END AS May,

    -- June 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-06-30' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-06-30')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-06-30' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-06-30'))
        ELSE 0
    END AS Jun,

    -- July 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-07-31' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-07-31')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-07-31' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-07-31'))
        ELSE 0
    END AS Jul,

    -- August 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-08-31' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-08-31')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-08-31' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-08-31'))
        ELSE 0
    END AS Aug,

    -- September 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-09-30' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-09-30')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-09-30' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-09-30'))
        ELSE 0
    END AS Sep,

    -- October 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-10-31' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-10-31')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-10-31' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-10-31'))
        ELSE 0
    END AS Oct,

    -- November 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-11-30' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-11-30')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-11-30' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-11-30'))
        ELSE 0
    END AS Nov,

    -- December 2025
    CASE
        WHEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-12-31' THEN sd.NetSalesValue ELSE 0 END), 0) >
             (ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-12-31')
        THEN ISNULL(SUM(CASE WHEN sd.InvoiceDate <= '2025-12-31' THEN sd.NetSalesValue ELSE 0 END), 0) -
             ((ab.LTM_At_Capture__c / 365.0) * DATEDIFF(day, ab.Actual_Close_Date__c, '2025-12-31'))
        ELSE 0
    END AS Dec

FROM AggregatedBase ab
LEFT JOIN SalesData2025 sd ON ab.Id = sd.Id
GROUP BY
    ab.Id,
    ab.OpportunityId,
    ab.Business_Plan_Level__c,
    ab.Product_Category__c,
    ab.Key_Initiative__c,
    ab.Key_Initiative_Year__c,
    ab.LTM_At_Capture__c,
    ab.Actual_Close_Date__c
ORDER BY ab.Id;
