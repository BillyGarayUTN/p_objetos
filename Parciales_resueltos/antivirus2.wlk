// Sistema de Antivirus

///////////////  COMPUTADORA ///////////////

class Computadora {
    var property carpetaDatos = []
    var property carpetaProgramas = []
    var property antivirus = null
    
    method instalarAntivirus(nuevoAntivirus) {
        antivirus = nuevoAntivirus
    }
    
    // PUNTO 1a: Gestión de archivos
    method agregarArchivo(archivo) {
        carpetaDatos.add(archivo)
    }
    
    method eliminarArchivo(archivo) {
        carpetaDatos.remove(archivo)
    }
    
    // PUNTO 1b: Gestión de programas
    method instalarPrograma(programa) {
        carpetaProgramas.add(programa)
    }
    
    method desinstalarPrograma(programa) {
        carpetaProgramas.remove(programa)
    }
    
    method ejecutarPrograma(programa) {
        if (self.puedeEjecutar(programa)) {
            return programa.ejecutar(self)  // Ejecución independiente
        } else {
            self.error("El programa no se puede ejecutar - es malware o antivirus no disponible")
        }
    }
    
    method puedeEjecutar(programa) = 
        !self.tieneAntivirus() || self.antivirusPermite(programa)
    
    method tieneAntivirus() = antivirus != null
    
    method antivirusPermite(programa) = 
        antivirus.puedeChequear() && antivirus.esSeguro(programa)
}

///////////////  ANTIVIRUS (JERARQUÍA) ///////////////

class Antivirus {
    var property baseMalwares = #{}  // Set de nombres de malwares conocidos
    
    method esSeguro(programa) = 
        !self.esMalware(programa)
    
    method esMalware(programa) = 
        baseMalwares.contains(programa.nombre()) || self.esMalwarePorTipo(programa)
    
    method esMalwarePorTipo(programa) = 
        programa.kindOf(Virus) || programa.kindOf(Ransomware)
    
    method actualizar(nuevosMalwares) {
        baseMalwares.addAll(nuevosMalwares)
    }
    
    // Método abstracto - cada tipo lo implementa
    method puedeChequear()
}

class AntivirusPago inherits Antivirus {
    override method puedeChequear() = true  // Sin restricciones
}

class AntivirusGratuito inherits Antivirus {
    var property fechaVencimiento
    
    override method puedeChequear() = new Date() <= fechaVencimiento
}

class AntivirusTrial inherits Antivirus {
    var property chequeosRestantes
    
    override method puedeChequear() {
        const puedeChequear = chequeosRestantes > 0
        if (puedeChequear) {
            chequeosRestantes -= 1
        }
        return puedeChequear
    }
}


///////////////  TIPOS DE ARCHIVOS ///////////////

class ArchivoTexto {
    var property nombreArchivo
    var property contenido

    method pesoMB() = (contenido.length() + nombreArchivo.length()) / 5
    
    method serAfectadoPorVirus(nombreVirus) {
        contenido = nombreVirus
    }
    
    method esComprobanteValido(cuentaBitcoin) = 
        nombreArchivo == "Comprobante de pago" && contenido.contains(cuentaBitcoin)
}

class Imagen {
    var property descripcion  // También es el nombre del archivo
    var property resolucionAlto
    var property resolucionAncho

    method nombreArchivo() = descripcion
    
    method resolucion() = resolucionAlto * resolucionAncho

    method pesoMB() = self.resolucion() / 100
    
    method serAfectadoPorVirus(nombreVirus) {
        // Da vuelta la resolución
        const altoAnterior = resolucionAlto
        resolucionAlto = resolucionAncho
        resolucionAncho = altoAnterior
        // Cambia descripción
        descripcion = "Brad Pitt dentro de un caballo de madera gigante"
    }
    
    method esComprobanteValido(cuentaBitcoin) = false  // Las imágenes no son comprobantes
}

class Musica {
    var property cancion
    var property artista
    var property anio
    var property pesoMB  // Peso dado directamente

    method nombreArchivo() = cancion + " - " + artista
    
    method serAfectadoPorVirus(nombreVirus) {
        // No afecta "Pronta Entrega"
        if (cancion != "Pronta Entrega") {
            artista = nombreVirus
        }
    }
    
    method esComprobanteValido(cuentaBitcoin) = false  // Los archivos de música no son comprobantes
}

///////////////  PROGRAMAS ///////////////

class Programa {
    var property nombre
    
    // Método abstracto - cada tipo lo implementa
    method ejecutar(computadora)
}

// 3a) Programa Normal
class ProgramaNormal inherits Programa {
    override method ejecutar(computadora) {
        // Hace mucho trabajo y crea archivo de texto
        const nuevoArchivo = new ArchivoTexto(
            nombreArchivo = "datos." + nombre,
            contenido = "información muy importante para el trabajo"
        )
        computadora.agregarArchivo(nuevoArchivo)
        return "Programa " + nombre + " ejecutado correctamente"
    }
}

// 3b) Virus
class Virus inherits Programa {
    override method ejecutar(computadora) {
        computadora.carpetaDatos().forEach { archivo => self.afectar(archivo) }
        return "Virus " + nombre + " ha infectado la computadora"
    }
    
    method afectar(archivo) {
        archivo.serAfectadoPorVirus(nombre)
    }
}

// 3c) Ransomware
class Ransomware inherits Programa {
    var property cuentaBitcoin
    var property bitcoinsRequeridos
    var property archivosOcultos = []  // Para poder restaurarlos
    
    override method ejecutar(computadora) {
        if (self.hayComprobantePago(computadora)) {
            // Restaurar archivos ocultos
            archivosOcultos.forEach { archivo => computadora.agregarArchivo(archivo) }
            archivosOcultos.clear()
            return "Archivos restaurados - Pago confirmado"
        } else {
            // Verificar si hay archivos para ocultar
            const archivosParaOcultar = computadora.carpetaDatos().filter { archivo => 
                archivo.nombreArchivo() != "README" 
            }
            
            if (archivosParaOcultar.isEmpty()) {
                self.error("No hay archivos para ocultar ni comprobante de pago")
            }
            
            // Ocultar archivos
            archivosParaOcultar.forEach { archivo => 
                computadora.eliminarArchivo(archivo)
                archivosOcultos.add(archivo)
            }
            
            // Crear archivo README
            const readme = new ArchivoTexto(
                nombreArchivo = "README",
                contenido = "Sus archivos han sido encriptados. Pague " + bitcoinsRequeridos + 
                           " bitcoins a la cuenta " + cuentaBitcoin + " para recuperarlos."
            )
            computadora.agregarArchivo(readme)
            
            return "Archivos encriptados - Pague para recuperar"
        }
    }
    
    method hayComprobantePago(computadora) {
        return computadora.carpetaDatos().any { archivo =>
            archivo.esComprobanteValido(cuentaBitcoin)
        }
    }
}

///////////////  PUNTO 6: BENCHMARK DE ANTIVIRUS ///////////////

object theUltimateAntivirusBenchmark {
    var property programasNormales = []
    var property malwares = []
    
    method mejorAntivirus(listaAntivirus) = 
        listaAntivirus.max { antivirus => self.puntajeAntivirus(antivirus) }
    
    method puntajeAntivirus(antivirus) = 
        self.aciertosEnProgramasNormales(antivirus) + self.aciertosEnMalwares(antivirus)
    
    method aciertosEnProgramasNormales(antivirus) = 
        programasNormales.count { programa => 
            antivirus.puedeChequear() && antivirus.esSeguro(programa)
        }
    
    method aciertosEnMalwares(antivirus) = 
        malwares.count { malware => 
            antivirus.puedeChequear() && !antivirus.esSeguro(malware)
        }
    
    // Métodos auxiliares para análisis detallado
    method evaluarAntivirus(antivirus) = [
        "Antivirus evaluado",
        "Programas normales detectados correctamente: " + self.aciertosEnProgramasNormales(antivirus),
        "Malwares detectados correctamente: " + self.aciertosEnMalwares(antivirus), 
        "Puntaje total: " + self.puntajeAntivirus(antivirus)
    ]
    
    method agregarProgramaNormal(programa) {
        programasNormales.add(programa)
    }
    
    method agregarMalware(malware) {
        malwares.add(malware)
    }
}
