# NoWay 📱

Una aplicación Flutter para descubrir y guardar frases de rechazo ("No"). Explora nuevas frases deslizándolas, guarda tus favoritos y personaliza la apariencia de la app.

![Flutter](https://img.shields.io/badge/Flutter-3.11.0-blue)
![Dart](https://img.shields.io/badge/Dart-3.11.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Características

- **Tarjetas deslizables**: Navega por frases con gestos intuitivos
  - Desliza a la derecha para añadir a favoritos ❤️
  - Desliza a la izquierda para ver la siguiente frase ➡️
- **Favoritos**: Guarda tus frases favoritas localmente
- **Sistema de temas**: Personaliza la apariencia de la app
  - Electric Orange 🌅
  - Deep Purple 💜
  - Cyber Teal 💠
  - Colores dinámicos (Android 12+ Material You) 🎨
  - Modo oscuro/claro 🌙
- **Soporte offline**: Vista especial cuando no hay conexión a internet
- **Navegación moderna**: Bottom navigation bar con 3 secciones

## 📱 Capturas de pantalla

| Home | Favoritos | Ajustes |
|------|-----------|----------|
| ![Home](https://via.placeholder.com/300x600?text=Home+Screen) | ![Favorites](https://via.placeholder.com/300x600?text=Favorites) | ![Settings](https://via.placeholder.com/300x600?text=Settings) |

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

3. **Ejecuta la app**
   ```bash
   flutter run
   ```

### Build para producción

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## 📦 Dependencias

| Paquete | Versión | Descripción |
|---------|---------|-------------|
| `provider` | ^6.1.1 | Gestión de estado |
| `dio` | ^5.4.0 | Cliente HTTP |
| `flutter_card_swiper` | ^7.2.0 | Tarjetas deslizables |
| `dynamic_color` | ^1.6.5 | Colores dinámicos (Material You) |
| `lottie` | ^3.3.2 | Animaciones |
| `connectivity_plus` | ^7.0.0 | Detección de conexión |
| `path_provider` | ^2.1.2 | Rutas del sistema |
| `shared_preferences` | ^2.2.2 | Almacenamiento local |

## 🏗️ Estructura del proyecto

```
lib/
├── main.dart                     # Punto de entrada de la app
├── core/
│   ├── models/
│   │   └── no_phrase.dart        # Modelo de datos de frase
│   └── services/
│       ├── api_service.dart      # Servicio API (NoWay API)
│       └── database_service.dart # Servicio de base de datos local
├── providers/
│   ├── connectivity_provider.dart  # Estado de conexión
│   ├── favorites_provider.dart     # Gestión de favoritos
│   ├── phrases_provider.dart       # Gestión de frases
│   └── theme_provider.dart        # Estado del tema
├── themes/
│   └── theme_manager.dart        # Gestor de temas
└── ui/
    ├── screens/
    │   ├── home_screen.dart      # Pantalla principal
    │   ├── favorites_screen.dart # Pantalla de favoritos
    │   └── settings_screen.dart # Pantalla de ajustes
    └── widgets/
        ├── error_offline_view.dart  # Vista offline
        ├── no_card.dart             # Tarjeta de frase
        └── swipeable_card.dart      # Tarjeta deslizables
```

## 🔌 API

La app se conecta a la **NoWay API** (`https://naas.isalman.dev`) para obtener frases de rechazo aleatorias.

### Endpoints disponibles

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/no` | Obtiene una frase aleatoria |
| GET | `/no/{id}` | Obtiene una frase por ID |

### Manejo de errores

- **Rate Limiting**: Máximo 120 peticiones por minuto
- **Timeout**: 30 segundos de espera
- **Offline**: Vista especial con opción de reintentar

## 🎨 Temas disponibles

| Tema | Color primario | Descripción |
|------|---------------|-------------|
| Electric Orange | Naranja | Vibrante y energético |
| Deep Purple | Púrpura | Elegante y moderno |
| Cyber Teal | Verde azulado | Futurista y fresco |
| Dynamic | Automático | Se adapta al fondo (Android 12+) |

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue primero para discutir los cambios que te gustaría hacer.

1. Fork el proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

Hecho con ❤️ usando Flutter
