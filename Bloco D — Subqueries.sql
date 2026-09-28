__Bloco D — Subqueries
__1. Clientes cujo gasto total está acima da média geral de gasto por cliente.

SELECT 
    o.customer_id,
    SUM(pay.payment_value) AS gasto_total
FROM 
    olist_orders_dataset o
JOIN 
    olist_order_payments_dataset pay ON o.order_id = pay.order_id
GROUP BY 
    o.customer_id
HAVING 
    SUM(pay.payment_value) > (
        
        SELECT AVG(gasto_por_cliente)
        FROM (
            SELECT SUM(p2.payment_value) AS gasto_por_cliente
            FROM olist_orders_dataset o2
            JOIN olist_order_payments_dataset p2 ON o2.order_id = p2.order_id
            GROUP BY o2.customer_id
        ) subquery_media
    )
ORDER BY 
    gasto_total DESC;
	
__2. Produtos que nunca receberam avaliação (NOT EXISTS / NOT IN).

SELECT 
    p.product_id,
    p.product_category_name
FROM 
    olist_products_dataset p
WHERE NOT EXISTS (
    SELECT 1 
    FROM olist_order_items_dataset i
    JOIN olist_order_reviews_dataset r ON i.order_id = r.order_id
    WHERE i.product_id = p.product_id
);

SELECT 
    p.product_id,
    p.product_category_name
FROM 
    olist_products_dataset p
WHERE p.product_id NOT IN (
    SELECT DISTINCT i.product_id
    FROM olist_order_items_dataset i
    JOIN olist_order_reviews_dataset r ON i.order_id = r.order_id
    WHERE i.product_id IS NOT NULL
);
__3. Vendedores que venderam produtos de mais de 5 categorias diferentes (subquery
com COUNT(DISTINCT ...)).

SELECT 
    sub.seller_id,
    sub.total_categorias
FROM (
  
    SELECT 
        i.seller_id,
        COUNT(DISTINCT p.product_category_name) AS total_categorias
    FROM 
        olist_order_items_dataset i
    JOIN 
        olist_products_dataset p ON i.product_id = p.product_id
    WHERE 
        p.product_category_name IS NOT NULL
    GROUP BY 
        i.seller_id
) sub
WHERE 
    sub.total_categorias > 5
ORDER BY 
    sub.total_categorias DESC;
	
__4. Pedidos cujo valor de frete (freight_value) é maior que o valor total dos itens do
próprio pedido (subquery correlacionada comparando as duas somas).

SELECT 
    o.order_id
FROM 
    olist_orders_dataset o
WHERE 
    (
        SELECT SUM(i.freight_value) - SUM(i.price)
        FROM olist_order_items_dataset i
        WHERE i.order_id = o.order_id
    ) > 0;