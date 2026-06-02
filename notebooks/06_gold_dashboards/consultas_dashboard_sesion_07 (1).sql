USE CATALOG workspace;

-- =============================================================
-- 0. Validación rápida de publicación Gold
-- Dataset sugerido: control_publicacion_gold
-- Visualización sugerida: tabla
-- =============================================================
SELECT
  schema_gold,
  tabla_gold,
  fuente_principal,
  granularidad,
  proposito,
  filas,
  estado_validacion,
  observaciones,
  fecha_publicacion
FROM workspace.control.gold_publication_summary_sesion_07
ORDER BY schema_gold, tabla_gold;

-- =============================================================
-- 1. LUMI — Tarjetas resumen ejecutivo
-- Dataset sugerido: lumi_resumen_cards
-- Visualización sugerida: counters / KPI cards
-- =============================================================
SELECT
  SUM(pedidos) AS total_pedidos,
  ROUND(SUM(venta_total_items), 2) AS venta_total_items,
  ROUND(SUM(venta_total_items) / NULLIF(SUM(pedidos), 0), 2) AS ticket_promedio_global,
  ROUND(AVG(tasa_entrega_tardia), 4) AS tasa_entrega_tardia_promedio
FROM workspace.lumi_gold.kpi_monthly_sales;

-- =============================================================
-- 2. LUMI — Ventas mensuales
-- Dataset sugerido: lumi_ventas_mensuales
-- Visualización sugerida: línea o barras por mes
-- Eje X: purchase_month
-- Ejes Y: venta_total_items, pedidos, ticket_promedio_items
-- =============================================================
SELECT
  purchase_month,
  pedidos,
  ROUND(venta_items, 2) AS venta_items,
  ROUND(valor_flete, 2) AS valor_flete,
  ROUND(venta_total_items, 2) AS venta_total_items,
  ticket_promedio_items,
  tasa_entrega_tardia
FROM workspace.lumi_gold.kpi_monthly_sales
WHERE purchase_month IS NOT NULL
ORDER BY purchase_month;

-- =============================================================
-- 3. LUMI — Top categorías por venta
-- Dataset sugerido: lumi_top_categorias
-- Visualización sugerida: barras horizontales
-- Eje X: venta_total_items
-- Eje Y: categoria_producto
-- =============================================================
SELECT
  categoria_producto,
  pedidos,
  items_vendidos,
  ROUND(venta_total_items, 2) AS venta_total_items,
  review_promedio,
  tasa_entrega_tardia
FROM workspace.lumi_gold.kpi_category_performance
ORDER BY venta_total_items DESC
LIMIT 15;

-- =============================================================
-- 4. LUMI — Métodos de pago
-- Dataset sugerido: lumi_metodos_pago
-- Visualización sugerida: barras o pie/donut
-- =============================================================
SELECT
  payment_type,
  pedidos,
  ROUND(valor_pagado_total, 2) AS valor_pagado_total,
  pago_promedio_por_pedido,
  cuotas_promedio
FROM workspace.lumi_gold.kpi_payment_methods
ORDER BY valor_pagado_total DESC;

-- =============================================================
-- 5. LUMI — Demora vs review
-- Dataset sugerido: lumi_demora_review
-- Visualización sugerida: barras por tramo de demora
-- Eje X: tramo_demora
-- Ejes Y: review_promedio, tasa_entrega_tardia, pedidos
-- =============================================================
SELECT
  tramo_demora,
  pedidos,
  review_promedio,
  demora_promedio_dias,
  tasa_entrega_tardia,
  reviews_bajas
FROM workspace.lumi_gold.kpi_delivery_review
ORDER BY
  CASE tramo_demora
    WHEN 'a_tiempo' THEN 1
    WHEN 'tarde_1_7_dias' THEN 2
    WHEN 'tarde_8_15_dias' THEN 3
    WHEN 'tarde_mas_15_dias' THEN 4
    WHEN 'sin_dato' THEN 5
    ELSE 99
  END;

-- =============================================================
-- 6. LUMI — Experiencia por estado del cliente
-- Dataset sugerido: lumi_experiencia_estado
-- Visualización sugerida: tabla o barras
-- =============================================================
SELECT
  customer_state,
  pedidos,
  review_promedio,
  tasa_entrega_tardia,
  reviews_bajas
FROM workspace.lumi_gold.kpi_customer_experience
WHERE customer_state IS NOT NULL
ORDER BY pedidos DESC;

-- =============================================================
-- 7. BAGAZO — Tarjetas resumen operativo
-- Dataset sugerido: bagazo_resumen_cards
-- Visualización sugerida: counters / KPI cards
-- =============================================================
SELECT
  COUNT(*) AS dias_ingenio_observados,
  COUNT(DISTINCT ingenio) AS ingenios,
  ROUND(AVG(lluvia_mm), 2) AS lluvia_promedio_mm,
  ROUND(AVG(cana_molida_ton), 2) AS cana_promedio_ton,
  ROUND(AVG(bagazo_entregado_ton), 2) AS bagazo_promedio_ton,
  SUM(CASE WHEN riesgo_bajo_bagazo THEN 1 ELSE 0 END) AS dias_riesgo_bajo_bagazo
FROM workspace.bagazo_gold.fact_operacion_ingenios;

-- =============================================================
-- 8. BAGAZO — Lluvia vs bagazo mensual por ingenio
-- Dataset sugerido: bagazo_lluvia_bagazo_mensual
-- Visualización sugerida: líneas por mes, con filtro de ingenio
-- =============================================================
SELECT
  anio_mes,
  ingenio,
  dias_observados,
  lluvia_promedio_mm,
  lluvia_total_mm,
  cana_promedio_ton,
  bagazo_promedio_ton,
  bagazo_total_ton,
  dias_riesgo_bajo_bagazo
FROM workspace.bagazo_gold.kpi_lluvia_bagazo_mensual
ORDER BY anio_mes, ingenio;

-- =============================================================
-- 9. BAGAZO — Ranking por ingenio
-- Dataset sugerido: bagazo_ranking_ingenio
-- Visualización sugerida: barras por ingenio
-- =============================================================
SELECT
  ingenio,
  dias_observados,
  bagazo_promedio_ton,
  bagazo_total_ton,
  cana_promedio_ton,
  lluvia_promedio_mm,
  dias_riesgo_bajo_bagazo
FROM workspace.bagazo_gold.kpi_bagazo_por_ingenio
ORDER BY bagazo_total_ton DESC;

-- =============================================================
-- 10. BAGAZO — Riesgo bajo de bagazo por mes e ingenio
-- Dataset sugerido: bagazo_riesgo_mensual
-- Visualización sugerida: heatmap o barras apiladas
-- =============================================================
SELECT
  ingenio,
  anio_mes,
  dias_observados,
  dias_riesgo,
  tasa_riesgo_bajo_bagazo,
  lluvia_promedio_mm,
  bagazo_promedio_ton
FROM workspace.bagazo_gold.kpi_riesgo_bajo_bagazo
ORDER BY anio_mes, ingenio;

-- =============================================================
-- 11. BAGAZO — Días secos vs lluviosos
-- Dataset sugerido: bagazo_secos_vs_lluviosos
-- Visualización sugerida: barras por tramo_lluvia e ingenio
-- =============================================================
SELECT
  ingenio,
  tramo_lluvia,
  dias_observados,
  lluvia_promedio_mm,
  cana_promedio_ton,
  bagazo_promedio_ton,
  dias_riesgo_bajo_bagazo
FROM workspace.bagazo_gold.kpi_dias_secos_vs_lluviosos
ORDER BY ingenio,
  CASE tramo_lluvia
    WHEN 'seco' THEN 1
    WHEN 'lluvia_baja' THEN 2
    WHEN 'lluvia_media' THEN 3
    WHEN 'lluvia_alta' THEN 4
    WHEN 'sin_dato_lluvia' THEN 5
    ELSE 99
  END;

-- =============================================================
-- 12. BAGAZO — Temporada lluviosa
-- Dataset sugerido: bagazo_temporada_lluviosa
-- Visualización sugerida: barras comparativas por temporada
-- =============================================================
SELECT
  ingenio,
  es_temporada_lluviosa,
  dias_observados,
  lluvia_promedio_mm,
  bagazo_promedio_ton,
  dias_riesgo_bajo_bagazo
FROM workspace.bagazo_gold.kpi_temporada_lluviosa
ORDER BY ingenio, es_temporada_lluviosa;
