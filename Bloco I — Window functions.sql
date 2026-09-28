__Bloco I — Window functions
__1. Ranking (RANK()) dos vendedores por faturamento dentro de cada estado.

WITH faturamento_por_vendedor AS (
   
    SELECT 
        s.seller_id,
        s.seller_state,
        SUM(oi.price)::NUMERIC as faturamento_total
    FROM olist_sellers_dataset s
    JOIN olist_order_items_dataset oi ON s.seller_id = oi.seller_id
    GROUP BY s.seller_id, s.seller_state
)

SELECT 
    seller_state as estado,
    seller_id as id_vendedor,
    faturamento_total,
    RANK() OVER (
        PARTITION BY seller_state 
        ORDER BY faturamento_total DESC
    ) as posicao_ranking
FROM faturamento_por_vendedor
ORDER BY estado, posicao_ranking;

__2. Faturamento mensal acumulado (SUM(...) OVER (ORDER BY ...)) por
vendedor.
WITH faturamento_mensal AS (
    
    SELECT 
        oi.seller_id,
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) as mes_ano,
        SUM(oi.price)::NUMERIC as faturamento_do_mes
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    GROUP BY oi.seller_id, DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)
)

SELECT 
    seller_id as id_vendedor,
    TO_CHAR(mes_ano, 'YYYY-MM') as mes,
    faturamento_do_mes,
    SUM(faturamento_do_mes) OVER (
        PARTITION BY seller_id 
        ORDER BY mes_ano
    ) as faturamento_acumulado
FROM faturamento_mensal
ORDER BY id_vendedor, mes_ano;

__3. Percentual de participação de cada vendedor no faturamento total do seu estado
(SUM(...) OVER (PARTITION BY estado)).

WITH faturamento_por_vendedor AS (
    
    SELECT 
        s.seller_id,
        s.seller_state,
        SUM(oi.price)::NUMERIC as faturamento_vendedor
    FROM olist_sellers_dataset s
    JOIN olist_order_items_dataset oi ON s.seller_id = oi.seller_id
    GROUP BY s.seller_id, s.seller_state
)

SELECT 
    seller_state as estado,
    seller_id as id_vendedor,
    faturamento_vendedor,
    
    ROUND(
        (faturamento_vendedor / SUM(faturamento_vendedor) OVER (PARTITION BY seller_state)) * 100, 
        2
    ) as percentual_participacao
FROM faturamento_por_vendedor
ORDER BY estado, faturamento_vendedor DESC;

__4. Variação de faturamento de um mês para o outro por vendedor, usando LAG().

WITH faturamento_mensal AS (
    
    SELECT 
        oi.seller_id,
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) as mes_ano,
        SUM(oi.price)::NUMERIC as faturamento_atual
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o ON oi.order_id = o.order_id
    GROUP BY oi.seller_id, DATE_TRUNC('month', o.order_purchase_timestamp::timestamp)
),
faturamento_com_anterior AS (
   
    SELECT 
        seller_id,
        mes_ano,
        faturamento_atual,
        LAG(faturamento_atual, 1, 0::NUMERIC) OVER (
            PARTITION BY seller_id 
            ORDER BY mes_ano
        ) as faturamento_anterior
    FROM faturamento_mensal
)

SELECT 
    seller_id as id_vendedor,
    TO_CHAR(mes_ano, 'YYYY-MM') as mes,
    faturamento_atual,
    faturamento_anterior,
    (faturamento_atual - faturamento_anterior) as variacao_bruta,
    
    CASE 
        WHEN faturamento_anterior = 0 THEN NULL
        ELSE ROUND(((faturamento_atual - faturamento_anterior) / faturamento_anterior) * 100, 2)
    END as variacao_percentual
FROM faturamento_com_anterior
ORDER BY id_vendedor, mes_ano;
