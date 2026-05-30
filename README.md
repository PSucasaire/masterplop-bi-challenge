# Masterplop BI Challenge

## Objetivo del Proyecto

El objetivo principal de este desafío fue diseñar e implementar una solución de Business Intelligence orientada a mejorar la toma de decisiones mediante análisis transaccional y evaluación de campañas cashback. La solución fue desarrollada siguiendo buenas prácticas de Analytics Engineering y Business Intelligence, priorizando rendimiento, organización del modelo y claridad analítica.

El proyecto busca entregar una visión ejecutiva del negocio, permitiendo identificar patrones de consumo, comportamiento regional, distribución por productos y el impacto financiero de campañas de incentivos.

---

# Arquitectura y Tecnologías Utilizadas

## Herramientas utilizadas

* DuckDB
* SQL
* Power BI
* Power Query
* VS Code

DuckDB fue utilizado como motor para el procesamiento y transformación de datos debido a su velocidad, simplicidad de implementación y capacidad analítica local sin necesidad de configurar motores tradicionales como SQL Server.

Power BI fue utilizado para el modelado visual y construcción del dashboard ejecutivo.

---

# Modelado de Datos

Se implementó un modelo dimensional tipo estrella con el objetivo de:

* Optimizar el rendimiento del dashboard.
* Reducir redundancia de información.
* Facilitar navegación analítica.
* Mejorar compresión y consumo de memoria en Power BI.
* Mantener una arquitectura escalable y organizada.

## Dimensiones Implementadas

* `dim_date`
* `dim_product`
* `dim_country_card`
* `dim_country_merchant`
* `dim_mcg`

---

# Fact Tables Implementadas

## fact_transactions_agg

Se creó una tabla fact agregada para evitar cargar toda la data transaccional al modelo de Power BI.

### Objetivos principales

* Reducir tamaño del modelo.
* Mejorar performance.
* Optimizar tiempos de respuesta.
* Reducir cardinalidad y redundancia.

---

## fact_cashback_agg

Se implementó una segunda fact table debido a que la lógica del cashback requería una granularidad diferente.

El cashback debía calcularse inicialmente a nivel `card_id`, ya que la campaña establecía un límite máximo de 50 USD por tarjeta. Posteriormente, el cashback fue distribuido proporcionalmente para habilitar análisis dimensionales sin perder consistencia financiera.

Esta estrategia permitió mantener simultáneamente:

* precisión financiera,
* y flexibilidad analítica.

---

# Dashboard Ejecutivo

El dashboard fue estructurado en tres vistas principales:

## 1. Resumen

Vista orientada a mostrar el comportamiento general del negocio y los KPIs principales.

### KPIs destacados

* Monto Total: **430.12M USD**
* Total Transacciones: **2.4M**
* Tarjetas Únicas: **2.4M**
* % Gasto Sin Contacto: **63.7%**

---

## 2. Desempeño

Vista enfocada en análisis regional y comercial.

### Principales hallazgos

* Brasil concentra aproximadamente el 20% del negocio.
* Las tarjetas de crédito representan el mayor volumen transaccional.
* Telecomunicaciones resgistra el ticket promedio más alto.
* México, Brasil y Argentina concentra el 55% del volumen de las transacciones

---

## 3. Campaña Cashback

Vista orientada a evaluar el impacto financiero y comportamiento de la campaña cashback.

### KPIs destacados

* Costo Total Cashback: **178.53K USD**
* Tarjetas Impactadas: **4.03K**
* Monto Elegible: **7.33M USD**
* Transacciones Elegibles: **28.89K**
* Ahorro por Tope Cashback: **334.17K USD**
* Cashback Promedio por Tarjeta: **44.3 USD**

---

# Decisiones Técnicas Clave

## Uso de dos Fact Tables

El principal trade-off técnico del proyecto fue trabajar con dos tablas fact con distinta granularidad:

* una tabla agregada orientada a visualización ejecutiva,
* y una tabla financiera orientada al cálculo correcto del cashback.

Esto permitió mantener rendimiento analítico sin comprometer reglas financieras del negocio.

---

## Estrategia Cashback

El cashback fue calculado inicialmente a nivel `card_id` para respetar correctamente la regla de tope máximo de 50 USD por tarjeta.

Posteriormente, se realizó una distribución proporcional para permitir análisis por:

* país,
* producto,
* fecha,
* y categoría comercial (MCG).

---

## Optimización Power BI

Se utilizaron medidas dinámicas y tablas de indicadores para:

* reducir cantidad de medidas físicas,
* optimizar memoria,
* mejorar mantenibilidad,
* y facilitar colaboración entre desarrolladores.

### Agrupación de categoría "Otros"

Para mejorar la legibilidad del dashboard y evitar sobrecarga visual en los gráficos regionales, los países con menor participación fueron agrupados bajo la categoría "Otros".

Esta estrategia permitió:

* priorizar la visualización de los países más representativos del negocio,
* mejorar interpretación ejecutiva,
* y optimizar el storytelling del análisis regional.

La categoría "Otros" representa la suma consolidada de países con menor participación individual dentro del monto total transaccional.

---




# Calidad y Escalabilidad

Durante el desarrollo se consideraron validaciones relacionadas a:

* duplicados,
* montos negativos,
* normalización de textos,
* consistencia dimensional,
* control de nulos.

---

## Mejoras Futuras

En un entorno productivo esta solución podría evolucionar hacia:

* arquitectura cloud,
* pipelines ELT automatizados,
* procesamiento distribuido con Spark,
* incremental loads,
* particionamiento,
* monitoreo de calidad de datos,
* orquestación de procesos.

---

# Conclusión

El proyecto permitió construir una solución de Analytics Engineering y Business Intelligence enfocada en rendimiento, análisis ejecutivo y consistencia financiera.

La implementación del modelo dimensional, la estrategia de cashback y el diseño ejecutivo del dashboard permitieron transformar información transaccional en insights accionables para la toma de decisiones.
