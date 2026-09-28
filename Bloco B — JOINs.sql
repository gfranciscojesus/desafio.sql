__Bloco B — JOINs
__1. Relatório com categoria do produto (traduzida), valor do item, cidade do vendedor.

SELECT 
    t.product_category_name_english AS categoria_traduzida,
    i.price AS valor_do_item,
    s.seller_city AS cidade_do_vendedor
FROM 
    olist_order_items_dataset i
JOIN 
    olist_products_dataset p 
    ON i.product_id = p.product_id
JOIN 
    product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
JOIN 
    olist_sellers_dataset s 
    ON i.seller_id = s.seller_id;
	
__2. Identificar pedidos com atraso na entrega, comparando data estimada com data real
de entrega (join entre orders e customers).

SELECT 
    o.order_id,
    o.order_status,
    o.order_estimated_delivery_date AS data_estimada,
    o.order_delivered_customer_date AS data_entrega_real
   FROM 
    olist_orders_dataset o
JOIN 
    olist_customers_dataset c 
    ON o.customer_id = c.customer_id
WHERE 
    o.order_delivered_customer_date > o.order_estimated_delivery_date;
	
__3. Listar pedidos e suas formas de pagamento, incluindo pedidos pagos em mais de
uma parcela (join entre orders e order_payments).

SELECT 
    o.order_id,
    o.order_status,
    p.payment_type AS forma_pagamento,
    p.payment_installments AS parcelas,
    p.payment_value AS valor_pago
FROM 
    olist_orders_dataset o
JOIN 
    olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE 
    p.payment_installments > 1;
	
__4. Listar produtos junto com a categoria traduzida, incluindo produtos cuja categoria
não possui tradução cadastrada (LEFT JOIN com
product_category_name_translation).

SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english
FROM 
    olist_products_dataset p
LEFT JOIN 
    product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;


__5. Identificar pedidos em que o cliente e o vendedor são do mesmo estado (join entre
customers, orders, order_items e sellers).

SELECT 
    o.order_id,
    c.customer_id,
    c.customer_state AS estado_cliente,
    s.seller_id,
    s.seller_state AS estado_vendedor
FROM 
    olist_orders_dataset o
JOIN 
    olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN 
    olist_order_items_dataset i ON o.order_id = i.order_id
JOIN 
    olist_sellers_dataset s ON i.seller_id = s.seller_id
WHERE 
    c.customer_state = s.seller_state;