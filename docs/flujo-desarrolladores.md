# Flujo de Trabajo para Desarrolladores

## Escenario B: Solo GitHub Actions (Recomendado)

En este escenario, los desarrolladores solo necesitan **Git** y un editor de texto. Todo el procesamiento, validación y despliegue se maneja automáticamente a través de GitHub Actions.

## Estructura de Carpetas

Los desarrolladores pueden crear su propia estructura organizacional bajo `gerencias/` siguiendo este patrón:

```
gerencias/
└── [nombre-gerencia]/
    └── [nombre-area]/
        ├── rol-[servicio]-[layer]-[ambiente]-[nombre].json
        ├── policy-[nombre-descriptivo].json
        └── policy-[otro-nombre].json
```

### Ejemplos de estructura:

```
gerencias/
├── sistemas/
│   └── aplicaciones/
│       ├── rol-webapp-backend-dev-api.json
│       ├── policy-s3-read-access.json
│       └── policy-dynamodb-basic.json
├── finanzas/
│   └── reportes/
│       ├── rol-etl-data-prod-processor.json
│       ├── policy-rds-read-access.json
│       └── policy-s3-reports-write.json
└── operaciones/
    ├── monitoreo/
    │   └── rol-cloudwatch-lambda-qa-alerts.json
    └── backup/
        └── rol-s3-backup-prod-scheduler.json
```

## Formato de Archivos

### 1. Archivo de Configuración de Rol

Nombre: `rol-[servicio]-[layer]-[ambiente]-[nombre].json`

```json
{
  "role_name": "rol-webapp-backend-dev-api",
  "description": "Descripción del rol",
  "trust_policy": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  },
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    ],
    "custom_policies": [
      "./policy-s3-read-access.json",
      "./policy-dynamodb-basic.json"
    ]
  },
  "tags": {
    "ambiente": "dev",
    "pais": "GT",
    "direccion": "Tecnología",
    "gerencia": "Sistemas",
    // ... resto de tags obligatorios
  }
}
```

### 2. Archivos de Política Separados

Nombre: `policy-[nombre-descriptivo].json`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::webapp-assets/*"
      ]
    }
  ]
}
```

## Ventajas de las Políticas Separadas

1. **Reutilización**: Una política puede ser referenciada por múltiples roles
2. **Mantenimiento**: Cambios en una política se aplican a todos los roles que la usan
3. **Claridad**: Cada archivo tiene un propósito específico y bien definido
4. **Versionado**: Cada política puede tener su propio historial de cambios

## Flujo de Trabajo del Desarrollador

### Paso 1: Crear la Estructura de Carpetas
```bash
# El desarrollador decide la organización
mkdir -p gerencias/[mi-gerencia]/[mi-area]
cd gerencias/[mi-gerencia]/[mi-area]
```

### Paso 2: Crear Archivos de Política
```bash
# Crear políticas reutilizables
cat > policy-s3-read-access.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::mi-bucket/*"]
    }
  ]
}
EOF
```

### Paso 3: Crear Configuración de Rol
```bash
# Crear configuración de rol que referencia las políticas
cat > rol-miapp-backend-dev-api.json << 'EOF'
{
  "role_name": "rol-miapp-backend-dev-api",
  "description": "Mi rol para la aplicación",
  "trust_policy": { ... },
  "policies": {
    "custom_policies": [
      "./policy-s3-read-access.json"
    ]
  },
  "tags": { ... }
}
EOF
```

### Paso 4: Validar Localmente (Opcional)
```bash
# Opcional: validar antes de hacer commit
python scripts/validate_iam.py gerencias/[mi-gerencia]/[mi-area]/
```

### Paso 5: Commit y Push
```bash
git add gerencias/[mi-gerencia]/[mi-area]/
git commit -m "feat: agregar rol para mi aplicación"
git push origin feature/mi-nuevo-rol
```

### Paso 6: GitHub Actions Automático
- **Validación automática** en Pull Request
- **Despliegue automático** al hacer merge a main
- **Notificaciones** de éxito o error por email/Slack

## Referencias de Política

Las referencias de política en el campo `custom_policies` pueden usar:

- **Ruta relativa con `./`**: `"./policy-s3-access.json"`
- **Ruta relativa sin `./`**: `"policy-s3-access.json"`
- **Ambas resuelven al mismo directorio que el archivo de rol**

## Validaciones Automáticas

GitHub Actions ejecuta las siguientes validaciones:

1. ✅ **Sintaxis JSON** válida en todos los archivos
2. ✅ **Convención de nombres** de roles
3. ✅ **Tags obligatorios** completos y válidos
4. ✅ **Estructura de políticas IAM** correcta
5. ✅ **Referencias de archivos** existentes
6. ✅ **Mejores prácticas de seguridad**

## Beneficios del Escenario B

- 🚀 **Simplicidad**: Solo necesitas Git y un editor
- 🔄 **Automatización completa**: Sin herramientas locales
- 🛡️ **Validación garantizada**: Imposible hacer deploy de configuraciones inválidas
- 📱 **Accesibilidad**: Funciona desde cualquier dispositivo con acceso a GitHub
- 👥 **Colaboración**: Pull Requests con revisión de código integrada
- 📊 **Auditoría**: Historial completo de cambios en Git

## Soporte

Para dudas sobre el flujo de trabajo, consulta:
- [Ejemplos completos](./examples/)
- [Documentación de validaciones](./docs/validaciones.md)
- [Troubleshooting](./docs/troubleshooting.md)
