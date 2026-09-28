--Bloco A — SELECT básico
--1. Listar os 20 pedidos com status delivered mais recentes, ordenados pela data de
entrega.

SELECT
    order_id,
    customer_id,
    order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_status = 'delivered'
ORDER BY order_delivered_customer_date desc -- [9-0]
LIMIT 20;

__2. Listar todos os produtos de uma categoria específica (usando a tabela de tradução
para filtrar pelo nome em português).
SELECT 
    p.*
FROM 
    olist_products_dataset p
JOIN 
    product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE 
    p.product_category_name = 'eletroportateis';

--3. Listar os métodos de pagamento distintos utilizados na base (SELECT DISTINCT
payment_type).

SELECT DISTINCT payment_type
FROM olist_order_payments_dataset
ORDER BY payment_type asc; -- [A-Z]

--4. Listar os produtos com peso (product_weight_g) acima de 10kg, ordenados do
mais pesado para o mais leve.

SELECT 
    product_id, 
    product_weight_g
FROM 
    olist_products_dataset
WHERE 
    product_weight_g > 10000
ORDER BY 
    product_weight_g DESC;

	

	
