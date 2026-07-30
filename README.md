# 🎥 GenScreenRecX

> **Grabador de pantalla gratuito, ligero, sin límites y sin marca de agua para Windows.**

<p align="center">

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)
![FFmpeg](https://img.shields.io/badge/FFmpeg-Compatible-007808?logo=ffmpeg&logoColor=white)
![Open Source](https://img.shields.io/badge/Open%20Source-Sí-success)
![Watermark](https://img.shields.io/badge/Marca%20de%20agua-Ninguna-brightgreen)
![License](https://img.shields.io/badge/Licencia-MIT-yellow)

</p>

---

## 🚀 ¿Qué es GenScreenRecX?

**GenScreenRecX** es una herramienta de grabación de pantalla para Windows desarrollada con **PowerShell y FFmpeg**.

Fue creada para ofrecer una alternativa sencilla, rápida y ligera que permita grabar la pantalla sin marcas de agua, publicidad, cuentas obligatorias ni funciones bloqueadas detrás de una suscripción.

Su interfaz funciona directamente desde la consola de Windows y permite configurar fácilmente la grabación, el micrófono y la calidad del video.

---

## ✨ Características principales

- 🎥 Grabación completa del escritorio.
- 🚫 Sin marca de agua.
- ⏱️ Sin límite artificial de duración.
- 💰 Totalmente gratuita.
- 🔓 Código abierto.
- 🎙️ Detección automática del micrófono.
- 🎚️ Selección de micrófono cuando existen varios dispositivos.
- ⚡ Diferentes perfiles de calidad.
- 🎞️ Codificación de video H.264.
- 🔊 Audio AAC.
- 📁 Organización automática de las grabaciones.
- 💻 Interfaz interactiva desde PowerShell.
- 🪶 Bajo consumo de recursos.
- 🔐 Sin necesidad de crear una cuenta.
- 📢 Sin publicidad.

---

## 🎯 ¿Por qué usar GenScreenRecX?

Muchos grabadores gratuitos incluyen restricciones como:

- Marcas de agua.
- Límites de tiempo.
- Publicidad.
- Registro obligatorio.
- Funciones bloqueadas.
- Suscripciones mensuales.
- Instaladores pesados.

**GenScreenRecX** elimina esas barreras y ofrece una herramienta directa, ligera y controlable por el usuario.

---

## 🖥️ Requisitos

- Windows 10 o Windows 11.
- PowerShell 5.1 o superior.
- FFmpeg instalado y agregado al `PATH`.
- Micrófono opcional.
- Espacio disponible en el almacenamiento.

---

## 📥 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/GensOsOfc/GenScreenRecX.git
cd GenScreenRecX
```

También puedes descargar el proyecto como archivo ZIP desde GitHub.

### 2. Instalar FFmpeg

GenScreenRecX utiliza FFmpeg para capturar y codificar el video.

Comprueba que FFmpeg esté disponible ejecutando:

```powershell
ffmpeg -version
```

### 3. Permitir la ejecución de scripts

Si Windows bloquea el script, ejecuta:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 4. Ejecutar GenScreenRecX

```powershell
.\GenScreenRecX.ps1
```

---

## 🎙️ Detección automática del micrófono

GenScreenRecX analiza los dispositivos de audio disponibles mediante DirectShow.

Ejemplos:

```text
Microphone (High Definition Audio Device)
Microphone Array (Realtek Audio)
USB Microphone
Headset Microphone
```

Si el equipo tiene un micrófono interno, la herramienta intenta detectarlo automáticamente.

Cuando existen varios dispositivos, puede mostrar un menú para seleccionar cuál deseas utilizar.

---

## 🎚️ Perfiles de calidad

| Perfil | CRF | Preset | Recomendado para |
|---|---:|---|---|
| 🚀 Rápido | 28 | superfast | Equipos de bajos recursos |
| ⚖️ Equilibrado | 23 | veryfast | Grabaciones generales |
| ⭐ Calidad | 18 | medium | Mejor calidad visual |

---

## 📦 Formato de salida

Las grabaciones se generan principalmente en formato:

```text
MP4
```

Configuración utilizada:

```text
Video: H.264
Audio: AAC
Captura: GDI Grab
Audio: DirectShow
```

---

## 📁 Estructura del proyecto

```text
GenScreenRecX/
│
├── GenScreenRecX.ps1
├── README.md
├── LICENSE
├── assets/
└── recordings/
```

---

## ⚙️ Tecnologías utilizadas

- PowerShell.
- FFmpeg.
- DirectShow.
- GDI Grab.
- H.264.
- AAC.

---

## 🛠️ Solución de problemas

### FFmpeg no se reconoce

Si aparece:

```text
ffmpeg no se reconoce como un comando
```

Debes instalar FFmpeg y agregar su carpeta `bin` al `PATH` de Windows.

### La ejecución de scripts está deshabilitada

Ejecuta:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### No se detecta el micrófono

Consulta los dispositivos disponibles con:

```powershell
ffmpeg -list_devices true -f dshow -i dummy
```

El error relacionado con `dummy` al final es normal. Lo importante es la lista de dispositivos mostrada anteriormente.

### Aparece `not enough frames to estimate rate`

Este mensaje suele ser una advertencia de FFmpeg:

```text
Stream #0: not enough frames to estimate rate
```

Generalmente no impide la grabación.

### El archivo se abre y se cierra inmediatamente

Ejecuta el script directamente desde PowerShell:

```powershell
.\GenScreenRecX.ps1
```

---

## 🔮 Próximas mejoras

- ⏸️ Pausar y reanudar grabaciones.
- 🖱️ Seleccionar una región de la pantalla.
- 🪟 Grabar una ventana específica.
- 🔊 Capturar el audio interno del sistema.
- 🎙️ Mezclar audio del sistema y micrófono.
- 📷 Agregar cámara web.
- ⌨️ Atajos globales de teclado.
- ⚙️ Archivo de configuración.
- 📊 Información de rendimiento.
- 🎞️ Grabación a diferentes FPS.
- 🖥️ Interfaz gráfica.
- 📦 Versión ejecutable.
- 🔄 Actualizaciones automáticas.

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas.

1. Haz un fork del repositorio.
2. Crea una nueva rama.
3. Realiza tus modificaciones.
4. Comprueba que el script funcione correctamente.
5. Envía un Pull Request.

```bash
git checkout -b nueva-funcion
git commit -m "Agregar nueva función"
git push origin nueva-funcion
```

---

## 🐛 Reportar errores

Al abrir un Issue, incluye:

- Versión de Windows.
- Versión de PowerShell.
- Versión de FFmpeg.
- Modelo o tipo de micrófono.
- Mensaje completo del error.
- Pasos para reproducir el problema.
- Capturas de pantalla, cuando sea posible.

---

## 🙏 Créditos

GenScreenRecX fue posible gracias a las tecnologías y comunidades que permiten desarrollar herramientas gratuitas y abiertas.

### Tecnologías

- **FFmpeg**, por proporcionar el motor multimedia utilizado para capturar, procesar y codificar las grabaciones.
- **Microsoft PowerShell**, por permitir crear la interfaz y automatizar el funcionamiento de la herramienta.
- **DirectShow**, por facilitar la detección y captura de dispositivos de audio en Windows.
- **GDI Grab**, por permitir la captura del escritorio.

### Comunidad

Gracias a todas las personas que:

- Prueban la herramienta.
- Reportan errores.
- Proponen nuevas funciones.
- Comparten el proyecto.
- Contribuyen con código o documentación.
- Apoyan el desarrollo de herramientas Open Source.

---

## 👨‍💻 Desarrollado por

# GeniousMods | GnDev

GenScreenRecX es un proyecto creado por **GeniousMods | GnDev**, enfocado en el desarrollo de herramientas ligeras, útiles, gratuitas y accesibles para la comunidad.

### GitHub

[github.com/GensOsOfc](https://github.com/GensOsOfc)

### YouTube

[@GeniousMods](https://www.youtube.com/@GeniousMods)

---

## 📜 Frase del proyecto

<p align="center">

### “Si puedes soñarlo, puedes programarlo.”

**— GeniousMods | GnDev**

</p>

---

## 📄 Licencia

GenScreenRecX se distribuye bajo la licencia MIT.

Esto permite utilizar, modificar y distribuir el proyecto respetando los términos de la licencia y conservando los avisos correspondientes.

Consulta el archivo `LICENSE` para obtener más información.

---

## ⭐ Apoya el proyecto

Si GenScreenRecX te resultó útil:

- Dale una estrella al repositorio.
- Comparte la herramienta.
- Reporta errores.
- Sugiere nuevas funciones.
- Contribuye al desarrollo.
- Suscríbete al canal de YouTube.

---

<p align="center">

<strong>GenScreenRecX</strong>

<br>

<strong>Sin marca de agua. Sin límites. Sin complicaciones.</strong>

<br><br>

<em>“Si puedes soñarlo, puedes programarlo.”</em>

<br><br>

Desarrollado por <strong>GeniousMods | GnDev</strong>

</p>
