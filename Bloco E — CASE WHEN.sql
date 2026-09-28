__Bloco E — CASE WHEN
__1. Classificar pedidos por prazo de entrega: "adiantado", "no prazo" ou "atrasado"
(comparando data real x estimada).

SELECT 
    order_id,
    order_delivered_customer_date AS data_real,
    order_estimated_delivery_date AS data_estimada,
    CASE 
        WHEN order_delivered_customer_date::date < order_estimated_delivery_date::date THEN 'adiantado'
        WHEN order_delivered_customer_date::date = order_estimated_delivery_date::date THEN 'no prazo'
        WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date THEN 'atrasado'
        ELSE 'sem dados'
    END AS status_prazo
FROM 
    olist_orders_dataset
WHERE 
    order_delivered_customer_date IS NOT NULL 
    AND order_delivered_customer_date != '' 
    AND order_estimated_delivery_date IS NOT NULL 
    AND order_estimated_delivery_date != '';

	
__2. Classificar clientes por faixa de gasto total: "bronze", "prata", "ouro".

SELECT 
    o.customer_id,
    SUM(p.payment_value) AS gasto_total,
    CASE 
        WHEN SUM(p.payment_value) < 150 THEN 'bronze'
        WHEN SUM(p.payment_value) <= 500 THEN 'prata'
        ELSE 'ouro'
    END AS faixa_cliente
FROM 
    olist_orders_dataset o
JOIN 
    olist_order_payments_dataset p 
    ON o.order_id = p.order_id
GROUP BY 
    o.customer_id
ORDER BY 
    gasto_total DESC;
__3. Classificar produtos por faixa de peso: "leve", "médio", "pesado" (com base em
product_weight_g).

SELECT 
    product_id,
    product_weight_g,
    CASE 
        WHEN product_weight_g < 1000 THEN 'leve'
        WHEN product_weight_g BETWEEN 1000 AND 5000 THEN 'médio'
        ELSE 'pesado'
    END AS faixa_peso
FROM 
    olist_products_dataset;
	
__4. Classificar pagamentos como "à vista" ou "parcelado", e dentro de parcelado
sinalizar parcelamentos longos (payment_installments > 6).

SELECT 
    order_id,
    payment_type,
    payment_installments,
    CASE 
        WHEN payment_installments = 1 THEN 'à vista'
        WHEN payment_installments > 1 AND payment_installments <= 6 THEN 'parcelado'
        WHEN payment_installments > 6 THEN 'parcelado longo'
    END AS tipo_parcelamento
FROM 
    olist_order_payments_dataset;