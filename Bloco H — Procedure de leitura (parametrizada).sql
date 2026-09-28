__Bloco H — Procedure de leitura (parametrizada)
__1. Criar a procedure/function sp_relatorio_vendedor(id_vendedor,
data_inicio, data_fim), que retorna faturamento, ticket médio e nota média
de avaliação do vendedor no período informado — sem alterar nenhum dado.

CREATE OR REPLACE FUNCTION sp_relatorio_vendedor(
    p_id_vendedor VARCHAR,
    p_data_inicio VARCHAR,
    p_data_fim VARCHAR
)
RETURNS TABLE (
    faturamento NUMERIC,
    ticket_medio NUMERIC,
    nota_media NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH dados_vendas AS (
        SELECT 
            COALESCE(SUM(oi.price), 0) as total_faturado,
            COUNT(DISTINCT oi.order_id) as total_pedidos
        FROM olist_order_items_dataset oi
        JOIN olist_orders_dataset o ON oi.order_id = o.order_id
        WHERE oi.seller_id = p_id_vendedor
          AND o.order_purchase_timestamp BETWEEN p_data_inicio::timestamp AND p_data_fim::timestamp
    ),
    dados_avaliacoes AS (
        SELECT 
            COALESCE(AVG(r.review_score), 0) as media_notas
        FROM olist_order_reviews_dataset r
        JOIN olist_order_items_dataset oi ON r.order_id = oi.order_id
        JOIN olist_orders_dataset o ON oi.order_id = o.order_id
        WHERE oi.seller_id = p_id_vendedor
          AND o.order_purchase_timestamp BETWEEN p_data_inicio::timestamp AND p_data_fim::timestamp
    )
    SELECT 
        v.total_faturado::NUMERIC,
        CASE 
            WHEN v.total_pedidos = 0 THEN 0::NUMERIC
            ELSE (v.total_faturado / v.total_pedidos)::NUMERIC
        END,
        a.media_notas::NUMERIC
    FROM dados_vendas v
    CROSS JOIN dados_avaliacoes a;

END;
$$ LANGUAGE plpgsql;

__2. Criar a procedure/function sp_relatorio_categoria(categoria,
data_inicio, data_fim), que retorna faturamento total e ticket médio da
categoria de produto no período informado.

CREATE OR REPLACE FUNCTION sp_relatorio_categoria(
    p_categoria VARCHAR,
    p_data_inicio VARCHAR,
    p_data_fim VARCHAR
)
RETURNS TABLE (
    faturamento_total NUMERIC,
    ticket_medio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH dados_categoria AS (
      
        SELECT 
            oi.order_id,
            oi.price
        FROM olist_order_items_dataset oi
        JOIN olist_orders_dataset o ON oi.order_id = o.order_id
        JOIN olist_products_dataset p ON oi.product_id = p.product_id
        WHERE p.product_category_name = p_categoria
          AND o.order_purchase_timestamp BETWEEN p_data_inicio::timestamp AND p_data_fim::timestamp
    )
    SELECT 
     
        COALESCE(SUM(price), 0)::NUMERIC as faturamento_total,
        
        
        CASE 
            WHEN COUNT(DISTINCT order_id) = 0 THEN 0::NUMERIC
            ELSE (COALESCE(SUM(price), 0) / COUNT(DISTINCT order_id))::NUMERIC
        END as ticket_medio
    FROM dados_categoria;

END;
$$ LANGUAGE plpgsql;