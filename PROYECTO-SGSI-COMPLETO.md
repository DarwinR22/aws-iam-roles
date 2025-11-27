# PROYECTO DEL CURSO: ESTÁNDARES DE SEGURIDAD

## **NOMBRE DEL PROYECTO:** 
Implementación de un Sistema de Gestión de Seguridad de la Información (SGSI)

---

## DESCRIPCIÓN DEL PROYECTO

El proyecto consiste en **diseñar e implementar un SGSI** que permita garantizar la **integridad, confidencialidad y disponibilidad** de la información, brindando confianza tanto a clientes como a proveedores. Se tomará en cuenta un **enfoque basado en riesgos**, siguiendo estándares internacionales de seguridad informática ampliamente aceptados.

### **Giro de Negocio:**
Se desarrollará un caso práctico para uno de los siguientes sectores:
- 🎓 **Educación**
- 🏦 **Banca**
- 🛒 **Retail**
- 📦 **Logística**

### **Opciones de Arquitectura:**
- ☁️ **Nube privada** (On-premise)
- 🌐 **Nube pública**
- 🔗 **Nube híbrida** con soporte para dispositivos móviles

---

## FASES DEL PROYECTO

### **Fase 1. Diseño de Infraestructura**

Crear un **diagrama de infraestructura** que garantice la viabilidad del proyecto y la resiliencia ante fallos o ataques. Este diagrama debe ser entregado al catedrático **una semana después** de haber entregado el enunciado de proyecto para su aprobación debida.

#### **Debe incluir:**
- 🖥️ **Servidores críticos** (de almacenamiento, aplicaciones, bases de datos, etc.)
- 🔌 **Periféricos** (switches, routers, etc.)
- 🛡️ **Firewalls de nueva generación** (NGFW) y sistemas **IDS/IPS**
- 🔒 **Segmentación de red** y **DMZ**
- 📦 **Tecnologías de virtualización** y **contenedores**
- 🔑 **Control de acceso basado en identidad** (IAM) y políticas **Zero Trust**
- 📊 **Herramientas de monitoreo y registro** (SIEM)

#### **Debe contemplar:**
- 🔄 **Servicios de redundancia**
- 📋 **Continuidad del negocio y recuperación ante desastres** (BCP/DRP), conforme al estándar **ISO 22301**
- 📝 **El diagrama va acompañado** de una descripción de toda la solución conceptual propuesta

---

### **Fase 2. Construcción del Ambiente Aprobado**

Una vez se cuente con la **aprobación del catedrático** y teniendo de insumo el diagrama de infraestructura del proyecto, construir el ambiente aprobado utilizando una de las siguientes opciones:

- ☁️ **Azure**
- 🌩️ **Amazon Web Services (AWS)**
- 🌐 **Google Cloud Platform (GCP)**

---

### **Fase 3. Selección de la gestión de la seguridad de la información**

El proyecto implementará **controles de seguridad** de acuerdo con:

#### **📋 ISO/IEC 27001 y 27002:**
- **Gestión de riesgos** de la seguridad de la información
- Basado en **inventarios de activos**
- **Análisis de riesgos** según **ISO/IEC 27005** o **NIST SP 800-30**
- **Evaluación de riesgos (BIA)** y **matriz de riesgos** para priorizar amenazas
- **Controles basados** en buenas prácticas **ISO/IEC 27002**

#### **🔒 Zero Trust Architecture:**
- Enfoque moderno de seguridad **Zero Trust**
- **Minimizar la confianza implícita** en la red
- **Autenticación continua**

#### **🛡️ NIST Cybersecurity Framework (CSF):**
Utilizado para evaluar, mitigar riesgos y gestionar incidentes cibernéticos, siguiendo las **cinco funciones:**
1. **Identificar**
2. **Proteger**
3. **Detectar**
4. **Responder**
5. **Recuperar**

#### **⚙️ ITIL/COBIT:**
- **Gestión de servicios de TI** y operaciones
- Siguiendo buenas prácticas de **ITIL v4** y **COBIT 2019**
- **Garantizar el alineamiento** de los objetivos de TI con los de la organización

#### **📊 ISO 22301 - Continuidad del negocio:**
- Desarrollar **planes de continuidad** basados en **ISO 22301**
- **Resiliencia del centro de datos** con **TIA-942**
- **Evaluando riesgos** y medidas de contingencia

---

### **Fase 4. Implementación de la solución seleccionada**

Se debe desarrollar los siguientes elementos:

- 📋 **Inventario de activos** (ISO/IEC 27005)
- 📊 **BIA: Análisis de impacto en el negocio** (ISO 22301)
- ⚠️ **Análisis de Riesgos** (NIST SP 800-30)
- 🎯 **Evaluación del Riesgo** (Modelo de gestión de Riesgos: OCTAVE)
- 🌡️ **Zona de Riesgo:** desarrollar la **matriz de calor** (ISO 22301)
- 📈 **Plan de Tratamiento Priorizado** (ISO 22301)

#### **🔐 Políticas de aseguramiento** (basados en los estándares que seleccionen):
- **Dominio**
- **Grupos**
- **Equipos**
- **Usuarios**
- **Conectividad a la Nube**
- **Conectividad a dispositivos móviles**

#### **🛡️ Controles a ser implementados** (basados en los estándares que seleccionen)

#### **✅ Buenas y mejores prácticas** para su implementación (basados en los estándares que seleccionen)

---

### **Fase 5. Uso e implementación de la gobernanza de la información**

Basado en **ITIL/COBIT**, aplicar para su escenario lo que concierne a:
- 🏢 **La Administración y gestión de servicios** del área de TI

---

### **Fase 6. Administración del Data Center**

Basado en **TIA 942** implementar:
- ✅ **Buenas y mejores prácticas** para su solución implementada

---

## FORMATO DE ENTREGA DE LA DOCUMENTACIÓN

### **Estructura del Documento:**

1. **📄 Portada**
2. **📑 Tabla de Contenido**
3. **📖 Introducción**
4. **🎓 Marco Teórico**
5. **🔬 Metodología**
6. **📊 Resultados**
   - 🏗️ **Diagrama de la solución** con su explicación de respaldo
   - 📋 **Inventario de activos** (ISO/IEC 27005)
   - 📊 **BIA: Análisis de impacto en el negocio** (ISO 22301)
   - ⚠️ **Análisis de Riesgos** (NIST SP 800-30)
   - 🎯 **Evaluación del Riesgo** (Modelo de gestión de Riesgos: OCTAVE)
   - 🌡️ **Zona de Riesgo:** desarrollar la **matriz de calor** (ISO 22301)
   - 📈 **Plan de Tratamiento Priorizado** (ISO 22301)
   - 🔐 **Políticas de aseguramiento** (basados en los estándares que seleccionen)
     - Dominio
     - Grupos
     - Equipos
     - Usuarios
     - Conectividad a la Nube
     - Conectividad a dispositivos móviles
   - 🛡️ **Controles a ser implementados** (basados en los estándares que seleccionen)
   - ✅ **Buenas y mejores prácticas** para su implementación (basados en los estándares que seleccionen)
   - 🏢 **La administración y gestión de Servicios** del área de TI (ITIL/COBIT)
   - 🏗️ **Buenas y mejores prácticas para el Data Center** (TIA 942)
7. **💬 Discusión**
8. **🎯 Conclusiones**
9. **📚 Referencias**
10. **📎 Anexos**

---

## TEMAS DE DISCUSIÓN

### **💬 Puntos de Discusión Requeridos:**

1. **🔒 ZTA en Nube Pública vs. Nube Híbrida**
   - Discusión sobre la implementación de **Zero Trust Architecture** en el entorno de nube pública vs. nube híbrida

2. **📱 MDM y DLP en Dispositivos Móviles**
   - Discusión sobre las mejores prácticas de **MDM (Mobile Device Management)** y **DLP (Data Loss Prevention)** en dispositivos móviles

3. **⚖️ Normativa y Cumplimiento en Seguridad Cloud**
   - **Impacto de la Normativa** y cumplimiento en la Seguridad en la Nube
   - ¿Qué consideraciones adicionales deben tomarse en cuenta para cumplir con las **normativas locales e internacionales**?

4. **🚨 Monitoreo y Detección de Amenazas SIEM**
   - **Efectividad de los sistemas** de detección y respuesta ante incidentes en tiempo real **(XDR, EDR)** en comparación con métodos tradicionales

5. **🏆 Certificación ISO/IEC 27001**
   - ¿Cómo mantener la **mejora continua post-certificación**?

6. **⚙️ ITIL versus COBIT**
   - ¿Cómo **alinear la seguridad de la información** con los objetivos de negocio a través de una **gestión de TI eficiente**?

---

## CALIFICACIÓN

### **📊 Escala de Calificación:**

- 🏆 **EXCELENTE (100% del Punteo):** Cumple al 100% con la solución debidamente aplicada
- ✅ **BUENO (80% del Punteo):** Cumple a un 80% con la solución debidamente aplicada
- ⚠️ **ACEPTABLE (60% del Punteo):** Cumple a un 60% con la solución debidamente aplicada
- ❌ **DEFICIENTE (40% del Punteo):** Cumple a un 40% con la solución debidamente aplicada
- 🚫 **NO ACEPTABLE (10% del Punteo):** Cumple con menos del 40% con la solución debidamente aplicada

### **🎯 Total del Proyecto: 40 Puntos**

### **📋 Tabla de Evaluación Detallada:**

| Elemento evaluado | Ponderación (puntos) | Excelente (100%) | Bueno (80%) | Aceptable (60%) | Deficiente (40%) | No Aceptable (10%) |
|-------------------|---------------------|------------------|-------------|-----------------|------------------|--------------------|
| **📚 Documentación General** | | | | | | **12 Puntos** |
| Introducción | 2 puntos | 2 | 1.6 | 1.2 | 0.8 | 0.2 |
| Marco Teórico | 1 punto | 1 | 0.8 | 0.6 | 0.4 | 0.1 |
| Metodología | 1 punto | 1 | 0.8 | 0.6 | 0.4 | 0.1 |
| Discusión | 4 puntos | 4 | 3.2 | 2.4 | 1.6 | 0.4 |
| Conclusiones | 4 puntos | 4 | 3.2 | 2.4 | 1.6 | 0.4 |
| **🔧 Contenido Específico** | | | | | | **28 Puntos** |
| Diagrama | 2 puntos | 2 | 1.6 | 1.2 | 0.8 | 0.2 |
| Inventario Activos | 2 puntos | 2 | 1.6 | 1.2 | 0.8 | 0.2 |
| BIA | 1 punto | 1 | 0.8 | 0.6 | 0.4 | 0.1 |
| Análisis de Riesgo | 2 puntos | 2 | 1.6 | 1.2 | 0.8 | 0.2 |
| Evaluación del Riesgo | 2 puntos | 2 | 1.6 | 1.2 | 0.8 | 0.2 |
| Zona de Riesgo | 2 puntos | 2 | 1.6 | 1.2 | 0.8 | 0.2 |
| Plan de Tratamiento Priorizado | 2 puntos | 2 | 1.6 | 1.2 | 0.8 | 0.2 |
| Políticas de aseguramiento | 3 puntos | 3 | 2.4 | 1.8 | 1.2 | 0.3 |
| Controles | 3 puntos | 3 | 2.4 | 1.8 | 1.2 | 0.3 |
| Buenas y mejores prácticas | 3 puntos | 3 | 2.4 | 1.8 | 1.2 | 0.3 |
| Administración y gestión de Servicios | 3 puntos | 3 | 2.4 | 1.8 | 1.2 | 0.3 |
| Buenas y mejores prácticas Data Center | 3 puntos | 3 | 2.4 | 1.8 | 1.2 | 0.3 |
| **🎯 TOTAL** | **40 Puntos** | **40** | **32** | **24** | **16** | **4** |

---

## NORMAS DE FORMATO

### **📄 Especificaciones del Documento:**

- **📏 Tamaño de hoja:** Carta (solo una cara)
- **🔤 Tipo de letra:** Arial, tamaño 12 normal
- **📐 Interlineado:** 1.5 para todo el texto
- **➡️ Sangrías:** 5 espacios en el primer renglón de cada párrafo
- **📏 Márgenes:**
  - **Izquierdo:** 3.5 cm
  - **Derecho:** 2.5 cm
  - **Superior e inferior:** 3 cm
- **🔢 Numeración:**
  - Todas las páginas (excepto portada e índice)
  - Numeración arábiga
  - Posición: ángulo superior derecho
- **📚 Citas y bibliografía:** Normas **APA** (última edición en español)

---

## ENTREGA DEL PROYECTO

### **📅 Fechas de Entrega:**

- **🎓 Maestrandos:** Décima semana del curso
- **📅 Plan fin de semana:** Quinta semana

### **📋 Modalidad:**
- **Entrega y presentación** al catedrático

---

## 🎯 ESTADO ACTUAL DEL PROYECTO SGSI

### **✅ IMPLEMENTADO (Nube Pública AWS):**

#### **🏗️ Arquitectura Completada:**
- **Fase 1:** ✅ Diagrama de infraestructura aprobado
- **Fase 2:** ✅ Ambiente AWS construido (5 capas)
- **Fase 3:** ✅ Estándares implementados:
  - ✅ ISO/IEC 27001/27002
  - ✅ NIST Cybersecurity Framework
  - ✅ Zero Trust Architecture
  - ✅ ISO 22301 (BCP/DRP)

#### **🔧 Componentes Técnicos:**
- ✅ **IAM Zero Trust** con ABAC
- ✅ **Segmentación de red** (5 capas de seguridad)
- ✅ **IDS/IPS** via CloudTrail + GuardDuty
- ✅ **SIEM** con CloudWatch + Security Hub
- ✅ **Backup automatizado** con AWS Backup
- ✅ **CI/CD seguro** con GitHub Actions

### **📋 PENDIENTE PARA DOCUMENTACIÓN:**

#### **Fase 4 - Elementos requeridos:**
- 📝 **Inventario de activos** formal (ISO/IEC 27005)
- 📊 **BIA detallado** (ISO 22301)
- ⚠️ **Análisis de riesgos** formal (NIST SP 800-30)
- 🎯 **Evaluación OCTAVE**
- 🌡️ **Matriz de calor** de riesgos
- 📈 **Plan de tratamiento priorizado**
- 🔐 **Políticas formales** documentadas

#### **Fase 5-6 - Gobernanza:**
- 🏢 **Documentación ITIL/COBIT**
- 🏗️ **Mejores prácticas TIA 942**

### **📊 Progreso del Proyecto:**
- **Técnico:** 95% ✅
- **Documentación:** 30% 📝
- **Cumplimiento estándares:** 90% ✅

---

**🎯 Objetivo:** Completar la documentación formal para alcanzar el **100% de cumplimiento** según la rúbrica de evaluación.