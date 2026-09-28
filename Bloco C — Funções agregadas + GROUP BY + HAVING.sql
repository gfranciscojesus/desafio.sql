__Bloco C — Funções agregadas + GROUP BY + HAVING
__1. Faturamento total por estado do cliente.

SELECT 
    c.customer_state AS estado_cliente,
    SUM(i.price) AS faturamento_total
FROM 
    olist_order_items_dataset i
JOIN 
    olist_orders_dataset o 
    ON i.order_id = o.order_id
JOIN 
    olist_customers_dataset c 
    ON o.customer_id = c.customer_id
GROUP BY 
    c.customer_state
ORDER BY 
    faturamento_total DESC;
__2. Top 10 vendedores por faturamento.

SELECT 
    seller_id,
    SUM(price) AS faturamento_vendedor
FROM 
    olist_order_items_dataset
GROUP BY 
    seller_id
ORDER BY 
    faturamento_vendedor DESC
LIMIT 10;
__3. Ticket médio por categoria de produto.

SELECT 
    p.product_category_name AS categoria_produto,
    AVG(i.price) AS ticket_medio
FROM 
    olist_order_items_dataset i
JOIN 
    olist_products_dataset p 
    ON i.product_id = p.product_id
WHERE 
    p.product_category_name IS NOT NULL
GROUP BY 
    p.product_category_name
ORDER BY 
    ticket_medio DESC;
	
__4. Vendedores com nota média de avaliação abaixo de 3 (HAVING AVG(...) < 3).

SELECT 
    i.seller_id,
    AVG(r.review_score) AS media_avaliacao
FROM 
    olist_order_reviews_dataset r
JOIN 
    olist_order_items_dataset i ON r.order_id = i.order_id
GROUP BY 
    i.seller_id
HAVING 
    AVG(r.review_score) < 3;

__5. Quantidade de pedidos por forma de pagamento (GROUP BY payment_type).

SELECT 
    payment_type AS forma_pagamento,
    COUNT(DISTINCT order_id) AS quantidade_pedidos
FROM 
    olist_order_payments_dataset
GROUP BY 
    payment_type
ORDER BY 
    quantidade_pedidos DESC;
	
__6. Peso médio dos produtos por categoria.

SELECT 
    product_id,
    product_category_name AS categoria,
    product_weight_g AS peso_gramas,
    CASE 
        WHEN product_weight_g < 1000 THEN 'leve'
        WHEN product_weight_g <= 5000 THEN 'médio'
        ELSE 'pesado'
    END AS classificacao_peso
FROM 
    olist_products_dataset
WHERE 
    product_weight_g IS NOT NULL;
	
__7. Número médio de parcelas (AVG(payment_installments)) por categoria de
produto.

SELECT 
    p.product_category_name AS categoria_produto,
    ROUND(AVG(pay.payment_installments), 2) AS media_parcelas
FROM 
    olist_order_payments_dataset pay
JOIN 
    olist_order_items_dataset i ON pay.order_id = i.order_id
JOIN 
    olist_products_dataset p ON i.product_id = p.product_id
WHERE 
    p.product_category_name IS NOT NULL
GROUP BY 
    p.product_category_name
ORDER BY 
    media_parcelas DESC;