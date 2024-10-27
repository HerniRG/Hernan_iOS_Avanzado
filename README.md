
# Dragon Ball - iOS Avanzado

## Descripción del Proyecto
**Dragon Ball** es una aplicación desarrollada como parte de la asignatura **iOS Avanzado** en **KeepCoding**. Permite a los usuarios explorar héroes del universo Dragon Ball, mostrar sus transformaciones, y localizaciones en un mapa interactivo. La app incluye funcionalidades como inicio de sesión seguro con JWT, almacenamiento de tokens en Keychain, y persistencia de datos local con Core Data.

## Funcionalidades
- **Splash Screen**: Pantalla de inicio atractiva.
- **Login**: Autenticación de usuarios utilizando **JSON Web Tokens (JWT)**. Los tokens se guardan de forma segura utilizando **Keychain**, permitiendo el acceso sin volver a iniciar sesión si el token sigue siendo válido.
- **Pantalla Principal**: Muestra una lista de héroes con opciones de búsqueda y ordenación alfabética.
- **Detalles del Héroe**: Información detallada sobre el héroe, incluyendo su imagen, descripción y transformaciones, con la posibilidad de ver cada transformación en un modal.
- **Mapa**: Visualización de las localizaciones de los héroes en un mapa utilizando **MapKit**. También incluye la funcionalidad de **Look Around**, similar a **Street View**, para explorar las localizaciones a nivel de calle.
- **Persistencia de Datos**: Uso de **Core Data** para almacenar héroes, localizaciones y transformaciones localmente.
- **Logout**: Función de logout que limpia la base de datos y elimina el token de autenticación del llavero (Keychain).
- **Test Unitarios**: Implementación de test unitarios para asegurar el correcto funcionamiento de la autenticación, el manejo de datos y otras funcionalidades.

## Imágenes
A continuación se presentan algunas capturas de pantalla de la aplicación:

<div style="display: flex; flex-wrap: wrap; justify-content: space-around;">
    <img src="https://live.staticflickr.com/65535/54089219620_427fc84daa_o.jpg" width="300" height="600" style="margin: 10px;"/>
    <img src="https://live.staticflickr.com/65535/54088763446_b9b37794d9_o.jpg" width="300" height="600" style="margin: 10px;"/>
    <img src="https://live.staticflickr.com/65535/54089219770_b1d62d097a_o.jpg" width="300" height="600" style="margin: 10px;"/>
    <img src="https://live.staticflickr.com/65535/54087884572_250fc424fe_o.jpg" width="300" height="600" style="margin: 10px;"/>
    <img src="https://live.staticflickr.com/65535/54089012613_65262dec61_o.jpg" width="300" height="600" style="margin: 10px;"/>
    <img src="https://live.staticflickr.com/65535/54089092774_7a408a7c05_o.jpg" width="300" height="600" style="margin: 10px;"/>
    <img src="https://live.staticflickr.com/65535/54089092789_05dae3be66_o.jpg" width="300" height="600" style="margin: 10px;"/>
</div>

## Cómo Comenzar
1. Clona el repositorio: `git clone https://github.com/HerniRG/Hernan_iOS_Avanzado.git`
2. Abre el proyecto en **Xcode**.
3. Ejecuta la aplicación en un simulador o dispositivo físico.

## Tecnologías Utilizadas
- **Swift**
- **MVVM**: Para la separación de la lógica de negocio y las vistas, utilizando observables.
- **MapKit** y **Look Around**: Para la visualización de localizaciones a nivel de calle.
- **KeychainSwift**: Para el almacenamiento seguro del token JWT.
- **Core Data**: Para la persistencia local de datos.
- **JWT**: Para la autenticación de usuarios.
- **Test Unitarios**: Para asegurar el correcto funcionamiento de la aplicación.

## Contribuciones
Las contribuciones son bienvenidas. Si tienes sugerencias o mejoras, no dudes en abrir un issue o pull request.

## Información del Desarrollador
**Hernán Rodríguez**  
Email: hernanrg85@gmail.com

---

Puedes ver el repositorio completo aquí: [Dragon Ball en GitHub](https://github.com/HerniRG/Hernan_iOS_Avanzado/)
