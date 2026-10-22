# RegisterBox

Punto de venta (POS) para iPhone y iPad. Permite gestionar productos, categorías, clientes, ventas y cobros. Funciona 100% offline y está preparada para sincronización futura con un backend.

## Características

- **POS** — venta rápida con carrito, chips de categoría, cobro pagado o en deuda, cálculo de cambio.
- **Inventario** — alta/edición de productos, badges de stock bajo y agotado, buscador, ajuste manual de stock con historial.
- **Clientes** — ficha con compras, deudas y registro de abonos.
- **Historial** — listado de ventas con filtros, detalle con artículos, pagos y saldos.
- **Ajustes** — edición de la tienda y gestión de categorías.
- **Onboarding** — configuración inicial guiada (tienda, categorías y productos).

## Reglas de negocio

- Una tienda activa por sesión.
- SKU único por tienda.
- No se puede vender ni agregar al carrito por encima del stock disponible.
- Ventas en deuda requieren cliente; al saldar los abonos la venta pasa a pagada automáticamente.
- Soft delete en todos los modelos (nada se borra físicamente).
- Las ventas guardan snapshot de nombre y precio del producto al momento de la venta.
- Cada venta y ajuste de stock registra un evento en el historial del producto.

## Stack

| Capa | Tecnología |
|---|---|
| UI | SwiftUI |
| Estado | `@Observable` (Observation, Swift 5.9+) |
| Persistencia local | SwiftData |
| Arquitectura | MVVM + Repository (servicios por protocolo) |
| Inyección de dependencias | `@Environment` |
| IDs | UUID v7 (ordenables por tiempo) |
| Tipografía | Rubik (bundled) |
| Backend futuro | Supabase (PostgreSQL) — stubs preparados |

## Arquitectura

```
View (SwiftUI)
  → ViewModel (@Observable)
    → Service (Protocol)
      → LocalXService (SwiftData)  /  RemoteXService (Supabase, pendiente)
```

Las vistas nunca acceden directamente a SwiftData: consumen protocolos de servicio inyectados vía `@Environment`. Al integrar Supabase se reemplaza la implementación local por la remota sin tocar las vistas.

## Estructura

```
RegisterBox/
├── App/            punto de entrada, estado global, DI
├── Models/         entidades SwiftData
├── ViewModels/     lógica de cada pantalla
├── Services/       Protocols · Local (SwiftData) · Remote (stubs)
├── Screens/        POS · Inventory · Customers · History · Settings · Onboarding
├── Components/     componentes reutilizables (RBButton, RBCard, ...)
├── DesignSystem/   colores, tipografía, espaciado
├── Cart/           carrito en memoria
├── Navigation/     TabView (iPhone) · SplitView (iPad)
└── Utils/          UUID v7, extensiones, registro de fuentes
```

## Requisitos

- Xcode 26+
- iOS / iPadOS 26.6+

## Ejecutar

Abre `RegisterBox.xcodeproj` en Xcode, selecciona un dispositivo o simulador y ejecuta (⌘R).
