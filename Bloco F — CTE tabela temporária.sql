__Bloco F — CTE / tabela temporária
__1. Construir uma CTE de faturamento mensal por estado e, a partir dela, calcular a
variação percentual de um mês para o outro.
WITH faturamento_mensal AS (
    SELECT 
        c.customer_state AS estado,
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS mes, 
        SUM(oi.price) AS faturamento_atual
    FROM 
        olist_orders_dataset o
    JOIN 
        olist_order_items_dataset oi ON o.order_id = oi.order_id
    JOIN 
        olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE 
        o.order_status = 'delivered'
    GROUP BY 
        c.customer_state, 
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) 
),
faturamento_com_anterior AS (
    SELECT 
        estado,
        mes,
        faturamento_atual,
        LAG(faturamento_atual) OVER (
            PARTITION BY estado 
            ORDER BY mes
        ) AS faturamento_anterior
    FROM 
        faturamento_mensal
)
SELECT 
    estado,
    TO_CHAR(mes, 'YYYY-MM') AS ano_mes,
    ROUND(faturamento_atual::numeric, 2) AS faturamento,
    ROUND(faturamento_anterior::numeric, 2) AS faturamento_mes_anterior,
    ROUND(
        ((faturamento_atual - faturamento_anterior) / faturamento_anterior * 100)::numeric, 
        2
    ) AS variacao_percentual
FROM 
    faturamento_com_anterior;

__2. Construir uma CTE com volume de avaliações e nota média por categoria de
produto, usada para identificar as categorias com pior reputação (nota média mais
baixa e volume relevante de avaliações).

WITH avaliacoes_categoria AS (
    SELECT 
        p.product_category_name AS categoria,
        COUNT(r.review_id) AS volume_avaliacoes,
        AVG(r.review_score::numeric) AS nota_media
    FROM 
        olist_order_reviews_dataset r
    JOIN 
        olist_order_items_dataset oi ON r.order_id = oi.order_id
    JOIN 
        olist_products_dataset p ON oi.product_id = p.product_id
    WHERE 
        p.product_category_name IS NOT NULL
    GROUP BY 
        p.product_category_name
)
SELECT 
    categoria,
    volume_avaliacoes,
    ROUND(nota_media, 2) AS nota_media
FROM 
    avaliacoes_categoria
WHERE 
    volume_avaliacoes > 50 
ORDER BY 
    nota_media ASC;
__3. Construir uma CTE de frete médio por estado do cliente, usada para comparar cada
estado com a média geral de frete.

WITH frete_medio_por_estado AS (
    SELECT 
        c.customer_state AS estado,
        AVG(oi.freight_value::numeric) AS frete_medio_estado 
    FROM 
        olist_order_items_dataset oi
    JOIN 
        olist_orders_dataset o ON oi.order_id = o.order_id
    JOIN 
        olist_customers_dataset c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_state
),
frete_geral AS (
    SELECT 
        AVG(freight_value::numeric) AS frete_medio_geral 
    FROM 
        olist_order_items_dataset
)
SELECT 
    e.estado,
    ROUND(e.frete_medio_estado, 2) AS frete_medio_estado,
    ROUND(g.frete_medio_geral, 2) AS frete_medio_geral,
    ROUND(e.frete_medio_estado - g.frete_medio_geral, 2) AS diferenca_para_media
FROM 
    frete_medio_por_estado e
CROSS JOIN 
    frete_geral g
ORDER BY 
    diferenca_para_media DESC;