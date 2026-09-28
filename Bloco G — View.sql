__Bloco G — View
__1. Criar a view vw_pedidos_completos, consolidando pedido, cliente, itens,
pagamento e vendedor, para servir de base a consultas analíticas futuras.

SELECT 
       o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp::timestamp AS data_compra,
    
       c.customer_unique_id,
    c.customer_state AS estado_cliente,
    c.customer_city AS cidade_cliente,
    
      oi.order_item_id,
    oi.product_id,
    oi.price AS preco_item,
    oi.freight_value AS frete_item,
    
      oi.seller_id,
    s.seller_state AS estado_vendedor,
    
      op.payment_sequential,
    op.payment_type AS tipo_pagamento,
    op.payment_installments AS parcelas,
    op.payment_value AS valor_pagamento
FROM 
    olist_orders_dataset o
LEFT JOIN 
    olist_customers_dataset c ON o.customer_id = c.customer_id
LEFT JOIN 
    olist_order_items_dataset oi ON o.order_id = oi.order_id
LEFT JOIN 
    olist_sellers_dataset s ON oi.seller_id = s.seller_id
LEFT JOIN 
    olist_order_payments_dataset op ON o.order_id = op.order_id;
	
__2. Criar a view vw_avaliacoes_categoria, consolidando nota média e volume de
avaliações por categoria de produto.


SELECT 
    p.product_category_name AS categoria,
    COUNT(r.review_id) AS volume_avaliacoes,
    ROUND(AVG(r.review_score::numeric), 2) AS nota_media
FROM 
    olist_order_reviews_dataset r
JOIN 
    olist_order_items_dataset oi ON r.order_id = oi.order_id
JOIN 
    olist_products_dataset p ON oi.product_id = p.product_id
WHERE 
    p.product_category_name IS NOT NULL
GROUP BY 
    p.product_category_name;