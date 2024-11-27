## total de casos de diabetes por año y alcaldía

SELECT alcaldia_id, periodo, SUM(casos_diabetes) as total_casos
FROM datos_diabetes
GROUP BY alcaldia_id, periodo
ORDER BY alcaldia_id, periodo;

## comparación del costo promedio anual entre tratamiento alopático y homeopático edad

SELECT grupo_edad, 
       AVG(costo_alopata_anual) as promedio_costo_alopata,
       AVG(costo_homeo_anual) as promedio_costo_homeo
FROM datos_diabetes
GROUP BY grupo_edad
ORDER BY grupo_edad;

## alcaldías con mayor proporción de casos de diabetes respecto a su población total en 2024
SELECT alcaldia_id, 
       SUM(casos_diabetes) as total_casos,
       SUM(poblacion_total) as poblacion_total,
       (SUM(casos_diabetes) * 100.0 / SUM(poblacion_total)) as porcentaje_casos
FROM datos_diabetes
WHERE periodo = 2024
GROUP BY alcaldia_id
ORDER BY porcentaje_casos DESC;

## tendencia de casos por año para cada edad

SELECT periodo, grupo_edad, SUM(casos_diabetes) as total_casos
FROM datos_diabetes
GROUP BY periodo, grupo_edad
ORDER BY periodo, grupo_edad;

## diferencia de costos totales entre tratamientos por alcaldía en 2024

SELECT alcaldia_id,
       SUM(costo_total_estimado_alopata) as total_alopata,
       SUM(costo_total_estimado_homeo) as total_homeo,
       SUM(costo_total_estimado_alopata - costo_total_estimado_homeo) as diferencia_costos
FROM datos_diabetes
WHERE periodo = 2024
GROUP BY alcaldia_id;

### incremento porcentual de casos entre 2020 y 2024 por alcaldía

SELECT 
    a.alcaldia_id,
    SUM(CASE WHEN a.periodo = 2020 THEN a.casos_diabetes END) as casos_2020,
    SUM(CASE WHEN a.periodo = 2024 THEN a.casos_diabetes END) as casos_2024,
    ((SUM(CASE WHEN a.periodo = 2024 THEN a.casos_diabetes END) - 
      SUM(CASE WHEN a.periodo = 2020 THEN a.casos_diabetes END)) * 100.0 / 
      SUM(CASE WHEN a.periodo = 2020 THEN a.casos_diabetes END)) as incremento_porcentual
FROM datos_diabetes a
WHERE a.periodo IN (2020, 2024)
GROUP BY a.alcaldia_id;

## distribución por género y su relación con casos de diabetes

SELECT alcaldia_id, periodo,
       SUM(poblacion_hombres) as total_hombres,
       SUM(poblacion_mujeres) as total_mujeres,
       SUM(casos_diabetes) as total_casos
FROM datos_diabetes
GROUP BY alcaldia_id, periodo
ORDER BY alcaldia_id, periodo;

## costo promedio por paciente (tanto alopático como homeopático) por grupo de edad en 2024

SELECT grupo_edad,
       AVG(costo_total_estimado_alopata / casos_diabetes) as costo_promedio_paciente_alopata,
       AVG(costo_total_estimado_homeo / casos_diabetes) as costo_promedio_paciente_homeo
FROM datos_diabetes
WHERE periodo = 2024
GROUP BY grupo_edad
ORDER BY grupo_edad;

## grupos de edad con mayor incremento de casos año tras año

SELECT 
    d1.alcaldia_id,
    d1.grupo_edad,
    d1.periodo as año_actual,
    d1.periodo - 1 as año_anterior,
    SUM(d1.casos_diabetes) as casos_actual,
    SUM(d2.casos_diabetes) as casos_anterior,
    ((SUM(d1.casos_diabetes) - SUM(d2.casos_diabetes)) * 100.0 / SUM(d2.casos_diabetes)) as incremento_porcentual
FROM datos_diabetes d1
JOIN datos_diabetes d2 
    ON d1.grupo_edad = d2.grupo_edad 
    AND d1.alcaldia_id = d2.alcaldia_id 
    AND d1.periodo = d2.periodo + 1
GROUP BY d1.alcaldia_id, d1.grupo_edad, d1.periodo
ORDER BY d1.periodo, d1.alcaldia_id, incremento_porcentual DESC;