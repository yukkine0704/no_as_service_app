# NoWay 📱

Una aplicación Flutter para descubrir y guardar frases de rechazo ("No"). Explora nuevas frases deslizándolas, guarda tus favoritos y personaliza la apariencia de la app con Material 3 Expressive.

![Flutter](https://img.shields.io/badge/Flutter-3.11.0+-blue)
![Dart](https://img.shields.io/badge/Dart-3.11.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Características

### 🎯 Núcleo
- **Tarjetas deslizables**: Navega por frases con gestos intuitivos
  - Desliza a la derecha para añadir a favoritos
  - Desliza a la izquierda para ver la siguiente frase
- **Favoritos**: Guarda tus frases favoritas localmente con persistencia
- **Modo offline inteligente**: Sistema avanzado de caché y reconexión automática

### 🎨 Personalización (Material 3 Expressive)
- **Sistema de temas M3E**: Diseño moderno con Material 3 Expressive
  - Electric Orange
  - Deep Purple
  - Cyber Teal
- **Colores dinámicos**: Soporte completo para Material You (Monet) en Android 12+
- **Modo oscuro/claro**: Transiciones suaves entre modos
- **Localización**: Soporte multilingüe (Español e Inglés)

### 🚀 Rendimiento y UX
- **Prefetching inteligente**: Carga anticipada de frases para navegación fluida
- **Skeleton loading**: Pantallas de carga elegantes mientras se obtienen datos
- **Rate limiting**: Protección cliente con 120 peticiones/minuto
- **Gestión de estado**: Providers con Provider pattern para estado reactivo
- **Animaciones fluidas**: Transiciones suaves entre tarjetas y pantallas

### 📡 Conectividad
- **Offline card**: Vista especial cuando se agotan las frases en caché
- **Auto-reconexión**: Detección automática de restauración de conexión
- **Monitoreo de red**: Seguimiento en tiempo real del estado de conexión
- **Caché persistente**: Frases guardadas para uso sin conexión

## 📱 Capturas de pantalla

| Home | Favoritos | Ajustes |
|------|-----------|----------|
| <img width="1344" height="2992" alt="Screenshot_20260304-214159" src="https://github.com/user-attachments/assets/c2199e19-d724-4ec3-adc7-27e59782e01d" /> | <img width="1344" height="2992" alt="Screenshot_20260304-214205" src="https://github.com/user-attachments/assets/50b523e0-ba16-4e55-b25d-74e4ccc8d06d" /> | <img width="1344" height="2992" alt="Screenshot_20260304-214209" src="https://github.com/user-attachments/assets/b5d39ab1-1510-43f5-986a-4b4a427d9199" /> |

## 🚀 Instalación

### Requisitos previos

- Flutter SDK 3.11.0 o superior
- Dart SDK 3.11.0 o superior
- Android SDK para Android
- Xcode para iOS (Mac)

### Pasos de instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/no_as_service_app.git
   cd no_as_service_app
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Genera los iconos de la app** (opcional)
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Ejecuta la app**
   ```bash
   flutter run
   ```

### Build para producción

#### Android
```bash
# APK
flutter build apk --release

# App Bundle (para Play Store)
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 📦 Dependencias

### Core
| Paquete | Versión | Descripción |
|---------|---------|-------------|
| `provider` | ^6.1.1 | Gestión de estado reactivo |
| `dio` | ^5.4.0 | Cliente HTTP con interceptores |
| `flutter_card_swiper` | ^7.2.0 | Tarjetas deslizables |
| `dynamic_color` | ^1.6.5 | Colores dinámicos Material You |
| `lottie` | ^3.3.2 | Animaciones Lottie |
| `connectivity_plus` | ^7.0.0 | Detección de conectividad |
| `path_provider` | ^2.1.2 | Rutas del sistema de archivos |
| `shared_preferences` | ^2.2.2 | Almacenamiento local persistente |

### Material 3 Expressive (M3E)
| Paquete | Versión | Descripción |
|---------|---------|-------------|
| `m3e_design` | ^0.2.1 | Sistema de diseño M3E base |
| `m3e_collection` | ^0.3.7 | Colección de componentes M3E |
| `app_bar_m3e` | ^0.1.2 | AppBar con estilos M3E |
| `icon_button_m3e` | ^0.2.1 | Botones de icono M3E |
| `button_m3e` | latest | Botones M3E |
| `fab_m3e` | latest | Floating Action Buttons M3E |
| `navigation_bar_m3e` | latest | Barra de navegación M3E |
| `button_group_m3e` | latest | Grupos de botones M3E |
| `loading_indicator_m3e` | ^0.1.1 | Indicadores de carga M3E |

### Dev Dependencies
| Paquete | Versión | Descripción |
|---------|---------|-------------|
| `flutter_launcher_icons` | ^0.14.3 | Generación de iconos de app |
| `build_runner` | ^2.4.8 | Generación de código |
| `flutter_lints` | ^6.0.0 | Linting de Flutter |

## 🏗️ Estructura del proyecto

```
lib/
├── main.dart                          # Punto de entrada de la app
├── core/
│   ├── enums/
│   │   └── offline_card_state.dart    # Estados del modo offline
│   ├── localization/
│   │   ├── localization_service.dart  # Servicio de internacionalización
│   │   ├── phrase_translation_service.dart  # Traducciones de frases
│   │   └── l10n/
│   │       └── ui_translations.dart   # Traducciones de UI (ES/EN)
│   ├── models/
│   │   └── no_phrase.dart             # Modelo de datos de frase
│   └── services/
│       ├── api_service.dart           # Servicio API con rate limiting
│       └── database_service.dart      # Servicio de base de datos local
├── providers/
│   ├── card_queue_manager.dart        # Gestor de cola de tarjetas y offline
│   ├── connectivity_provider.dart     # Estado de conexión
│   ├── favorites_provider.dart        # Gestión de favoritos
│   ├── locale_provider.dart           # Gestión de idioma
│   ├── phrases_provider.dart          # Gestión de frases
│   └── theme_provider.dart            # Estado del tema
├── themes/
│   └── theme_manager.dart             # Gestor de temas M3E
└── ui/
    ├── screens/
    │   ├── home_screen.dart           # Pantalla principal con swiper
    │   ├── favorites_screen.dart      # Pantalla de favoritos
    │   └── settings_screen.dart       # Pantalla de ajustes
    └── widgets/
        ├── error_offline_view.dart    # Vista de error offline
        ├── no_card.dart               # Tarjeta de frase individual
        ├── offline_card.dart          # Tarjeta de modo offline
        ├── rate_limit_card.dart       # Tarjeta de límite de peticiones
        ├── skeleton_card.dart         # Esqueleto de carga
        └── swipeable_card.dart        # Tarjeta deslizable con gestos
```

## 🔌 API

La app se conecta a la **NoWay API** (`https://naas.isalman.dev`) para obtener frases de rechazo aleatorias.

### Endpoints disponibles

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/no` | Obtiene una frase aleatoria |

### Características del cliente API

- **Rate Limiting cliente**: Máximo 120 peticiones por minuto (token bucket)
- **Timeout**: 30 segundos de espera
- **Reintentos automáticos**: Manejo de errores de red
- **Caché de respuestas**: Almacenamiento local de frases

### Manejo de errores

| Error | Descripción | Comportamiento |
|-------|-------------|----------------|
| Rate Limit (429) | Límite de peticiones excedido | Muestra tarjeta especial con cooldown |
| Network Error | Sin conexión a internet | Activa modo offline con frases en caché |
| Timeout | Tiempo de espera excedido | Reintentar automático |

## 🎨 Temas disponibles

| Tema | Color primario | Descripción |
|------|---------------|-------------|
| Electric Orange | `#FF6B35` | Vibrante y energético |
| Deep Purple | `#6750A4` | Elegante y moderno |
| Cyber Teal | `#00BFA5` | Futurista y fresco |
| Dynamic (Monet) | Automático | Se adapta al fondo de pantalla (Android 12+) |

## 🌍 Internacionalización

La app soporta dos idiomas:

| Idioma | Código | Bandera |
|--------|--------|---------|
| English | `en` | 🇺🇸 |
| Español | `es` | 🇪🇸 |

Las traducciones se encuentran en [`lib/core/localization/l10n/ui_translations.dart`](lib/core/localization/l10n/ui_translations.dart).

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue primero para discutir los cambios que te gustaría hacer.

1. Fork el proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

Hecho con ❤️ y muchos "No" usando Flutter

<p align="center">
  <img src="assets/images/logo.png" width="120" alt="NoWay Logo">
</p>
