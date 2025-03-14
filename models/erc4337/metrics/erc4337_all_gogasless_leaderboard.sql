{{ config
(
    materialized = 'table',
    copy_grants=true
)
}}

  SELECT 
      COALESCE(l.NAME, u.CALLED_CONTRACT) AS PROJECT,
      COALESCE(m.LOGO, 'https://tspekraxapsoevhxjafh.supabase.co/storage/v1/object/public/logos//other.png') AS LOGO, 
      m.WEBSITE,
      m.CATEGORY,
    
      SUM(CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '7 days' THEN ACTUALGASCOST_USD ELSE 0 END) AS PAYMASTER_VOLUME_7D,
      COUNT(DISTINCT CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '7 days' THEN u.SENDER END) AS ACTIVE_ACCOUNTS_7D,
      COUNT(CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '7 days' THEN u.OP_HASH END) AS GASLESS_TXNS_7D,
      ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '7 days' THEN u.SENDER END) DESC) AS RN_7D,

      SUM(CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '30 days' THEN ACTUALGASCOST_USD ELSE 0 END) AS PAYMASTER_VOLUME_30D,
      COUNT(DISTINCT CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '30 days' THEN u.SENDER END) AS ACTIVE_ACCOUNTS_30D,
      COUNT(CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '30 days' THEN u.OP_HASH END) AS GASLESS_TXNS_30D,
      ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '30 days' THEN u.SENDER END) DESC) AS RN_30D,

      SUM(CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '90 days' THEN ACTUALGASCOST_USD ELSE 0 END) AS PAYMASTER_VOLUME_90D,
      COUNT(DISTINCT CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '90 days' THEN u.SENDER END) AS ACTIVE_ACCOUNTS_90D,
      COUNT(CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '90 days' THEN u.OP_HASH END) AS GASLESS_TXNS_90D,
      ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT CASE WHEN u.BLOCK_TIME > CURRENT_DATE - INTERVAL '90 days' THEN u.SENDER END) DESC) AS RN_90D
  FROM BUNDLEBEAR.DBT_KOFI.ERC4337_ALL_USEROPS u
  INNER JOIN BUNDLEBEAR.DBT_KOFI.ERC4337_LABELS_APPS l 
      ON u.CALLED_CONTRACT = l.ADDRESS
      AND l.CATEGORY != 'factory'
  LEFT JOIN BUNDLEBEAR.DBT_KOFI.ERC4337_LABELS_APP_METADATA m 
      ON m.NAME = l.NAME
  WHERE u.BLOCK_TIME > CURRENT_DATE - INTERVAL '90 days' 
      AND u.BLOCK_TIME < CURRENT_DATE
      AND u.PAYMASTER != '0x0000000000000000000000000000000000000000'
  GROUP BY 1,2,3,4