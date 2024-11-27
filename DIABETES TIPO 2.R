## conexción con mysql workbench

install.packages("RMySQL")
install.packages("DBI")

library(RMySQL)
library(DBI)

con <- dbConnect(MySQL(),
                 user = "root",
                 password = "******",
                 dbname = "diabetes_tip_2",
                 host = "localhost",
                 port = 3306)

## verificamos la base de datos 


dbListTables(con)
datos_diabetes <- dbGetQuery(con, "SELECT * FROM datos_diabetes")
head(datos_diabetes)


## carogamos las paqueterias 
library(dplyr)
library(tidyr)

#### realizamos las consultas previas de mysql
##
consulta1 <- datos_diabetes %>%
  group_by(alcaldia_id, periodo) %>%
  summarise(total_casos = sum(casos_diabetes)) %>%
  arrange(alcaldia_id, periodo)
consulta1


#####
consulta2 <- datos_diabetes %>%
  group_by(grupo_edad) %>%
  summarise(
    promedio_costo_alopata = mean(costo_alopata_anual),
    promedio_costo_homeo = mean(costo_homeo_anual)
  ) %>%
  arrange(grupo_edad)

print(consulta2)

### 
consulta3 <- datos_diabetes %>%
  filter(periodo == 2024) %>%
  group_by(alcaldia_id) %>%
  summarise(
    total_casos = sum(casos_diabetes),
    poblacion_total = sum(poblacion_total),
    porcentaje_casos = (total_casos * 100 / poblacion_total)
  ) %>%
  arrange(desc(porcentaje_casos))

print(consulta3)

####
consulta4 <- datos_diabetes %>%
  group_by(periodo, grupo_edad) %>%
  summarise(total_casos = sum(casos_diabetes)) %>%
  arrange(periodo, grupo_edad)

print(consulta4)

######
consulta5 <- datos_diabetes %>%
  filter(periodo == 2024) %>%
  group_by(alcaldia_id) %>%
  summarise(
    total_alopata = sum(costo_total_estimado_alopata),
    total_homeo = sum(costo_total_estimado_homeo),
    diferencia_costos = sum(costo_total_estimado_alopata - costo_total_estimado_homeo)
  )

print(consulta5)

####
consulta6 <- datos_diabetes %>%
  filter(periodo %in% c(2020, 2024)) %>%
  group_by(alcaldia_id) %>%
  summarise(
    casos_2020 = sum(casos_diabetes[periodo == 2020]),
    casos_2024 = sum(casos_diabetes[periodo == 2024]),
    incremento_porcentual = ((casos_2024 - casos_2020) * 100 / casos_2020)
  )

print(consulta6)

###
consulta7 <- datos_diabetes %>%
  group_by(alcaldia_id, periodo) %>%
  summarise(
    total_hombres = sum(poblacion_hombres),
    total_mujeres = sum(poblacion_mujeres),
    total_casos = sum(casos_diabetes)
  ) %>%
  arrange(alcaldia_id, periodo)

print(consulta7)

######
consulta8 <- datos_diabetes %>%
  filter(periodo == 2024) %>%
  group_by(grupo_edad) %>%
  summarise(
    costo_promedio_paciente_alopata = mean(costo_total_estimado_alopata / casos_diabetes),
    costo_promedio_paciente_homeo = mean(costo_total_estimado_homeo / casos_diabetes)
  ) %>%
  arrange(grupo_edad)

print(consulta8)

####

consulta9 <- datos_diabetes %>%
  arrange(alcaldia_id, grupo_edad, periodo) %>%
  group_by(alcaldia_id, grupo_edad) %>%
  mutate(
    año_anterior = lag(periodo),
    casos_anterior = lag(casos_diabetes),
    incremento_porcentual = ((casos_diabetes - lag(casos_diabetes)) * 100 / lag(casos_diabetes))
  ) %>%
  filter(!is.na(incremento_porcentual)) %>%
  select(alcaldia_id, grupo_edad, periodo, año_anterior, 
         casos_diabetes, casos_anterior, incremento_porcentual) %>%
  arrange(periodo, alcaldia_id, desc(incremento_porcentual))

print(consulta9)



##### graficamos 

ggplot(consulta2) +
  geom_bar(aes(x = grupo_edad, y = promedio_costo_alopata, fill = "Alópata"), stat = "identity") +
  geom_bar(aes(x = grupo_edad, y = promedio_costo_homeo, fill = "Homeopático"), stat = "identity", position = position_nudge(x = 0.3)) +
  labs(title = "Costo promedio por grupo de edad (Barras independientes)",
       x = "Grupo de Edad",
       y = "Costo Promedio",
       fill = "Tipo de Tratamiento") +
  theme_minimal()


