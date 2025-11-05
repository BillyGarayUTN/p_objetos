// Sistema Academia de Cocina

///////////////  COCINERO ///////////////

class Cocinero {
    const property nombre
    var property nivel = new Principiante()
    const property preparaciones = []
    
    // PUNTO 1: Experiencia adquirida
    method experiencia() = preparaciones.sum { comida => comida.experienciaQueAporta() }
    
    // PUNTO 2: Superó nivel de aprendizaje
    method superoNivel() = nivel.superoNivel(self)
    
    // PUNTO 3: Preparar una comida
    method preparar(receta) {
        if (!nivel.puedePreparar(receta, self)) {
            throw new DomainException(message = "No puede preparar esta receta con su nivel actual")
        }
        
        const comida = nivel.prepararComida(receta, self)
        preparaciones.add(comida)
        
        // Evaluar si pasa al siguiente nivel
        if (self.superoNivel()) {
            nivel = nivel.siguienteNivel()
        }
        
        return comida
    }
    
    // Métodos de apoyo para los niveles
    method comidasDificiles() = preparaciones.count { comida => comida.receta().esDificil() }
    
    method preparacionesSimilaresA(receta) = 
        preparaciones.filter { comida => comida.receta().esSimilarA(receta) }
    
    method experienciaEnRecetasSimilaresA(receta) = 
        self.preparacionesSimilaresA(receta).sum { comida => comida.experienciaQueAporta() }
    
    method cantidadComidasSimilaresA(receta) = self.preparacionesSimilaresA(receta).size()
    
    override method toString() = nombre + " (Nivel: " + nivel.nombre() + ", Exp: " + self.experiencia() + ")"
}

///////////////  NIVELES DE APRENDIZAJE ///////////////

class Nivel {
    method puedePreparar(receta, cocinero)
    method prepararComida(receta, cocinero)
    method superoNivel(cocinero)
    method siguienteNivel()
    method nombre()
}

class Principiante inherits Nivel {
    
    override method puedePreparar(receta, cocinero) = !receta.esDificil()
    
    override method prepararComida(receta, cocinero) {
        const calidad = if (receta.ingredientes().size() < 4) "normal" else "pobre"
        return new Comida(receta = receta, calidad = calidad)
    }
    
    override method superoNivel(cocinero) = cocinero.experiencia() > 100
    
    override method siguienteNivel() = new Experimentado()
    
    override method nombre() = "Principiante"
}

class Experimentado inherits Nivel {
    
    override method puedePreparar(receta, cocinero) = 
        !receta.esDificil() || self.conoceRecetaSimilar(receta, cocinero)
    
    method conoceRecetaSimilar(receta, cocinero) = 
        cocinero.preparacionesSimilaresA(receta).size() > 0
    
    override method prepararComida(receta, cocinero) {
        if (self.perfeccionoReceta(receta, cocinero)) {
            const plus = cocinero.cantidadComidasSimilaresA(receta) / 10
            return new Comida(receta = receta, calidad = "superior", plus = plus)
        } else {
            return new Comida(receta = receta, calidad = "normal")
        }
    }
    
    method perfeccionoReceta(receta, cocinero) {
        const experienciaRequerida = receta.experienciaBase() * 3
        return cocinero.experienciaEnRecetasSimilaresA(receta) >= experienciaRequerida
    }
    
    override method superoNivel(cocinero) = cocinero.comidasDificiles() > 5
    
    override method siguienteNivel() = new Chef()
    
    override method nombre() = "Experimentado"
}

class Chef inherits Experimentado {
    
    override method puedePreparar(receta, cocinero) = true  // Puede preparar cualquier receta
    
    override method superoNivel(cocinero) = false  // No se puede superar el nivel chef
    
    override method siguienteNivel() {
        throw new DomainException(message = "Chef es el nivel máximo")
    }
    
    override method nombre() = "Chef"
}

///////////////  RECETAS ///////////////

class Receta {
    const property ingredientes = []
    const property dificultad
    
    method esDificil() = dificultad > 5 || ingredientes.size() > 10
    
    method esSimilarA(otraReceta) = 
        self.mismoIngredientes(otraReceta) || self.dificultadSimilar(otraReceta)
    
    method mismoIngredientes(otraReceta) = ingredientes == otraReceta.ingredientes()
    
    method dificultadSimilar(otraReceta) = (dificultad - otraReceta.dificultad()).abs() <= 1
    
    // Experiencia base que aporta la receta (sin considerar calidad)
    method experienciaBase() = ingredientes.size() * dificultad
    
    override method toString() = "Receta (Dif: " + dificultad + ", Ing: " + ingredientes.size() + ")"
}

// PUNTO 4: Recetas gourmet
class RecetaGourmet inherits Receta {
    
    override method experienciaBase() = super() * 2  // Doble de experiencia
    
    override method esDificil() = true  // Siempre son difíciles
    
    override method toString() = "Receta Gourmet (Dif: " + dificultad + ", Ing: " + ingredientes.size() + ")"
}

///////////////  COMIDAS PREPARADAS ///////////////

class Comida {
    const property receta
    const property calidad
    var property plus = 0  // Para comidas superiores
    
    method experienciaQueAporta() {
        return calidad match {
            "pobre" => receta.experienciaBase().min(configuracion.experienciaMaximaPobre())
            "normal" => receta.experienciaBase()
            "superior" => receta.experienciaBase() + plus
        }
    }
    
    override method toString() = "Comida " + calidad + " (" + receta.toString() + ")"
}

///////////////  CONFIGURACIÓN GLOBAL ///////////////

object configuracion {
    var property experienciaMaximaPobre = 4  // Valor configurable
}

///////////////  ACADEMIA ///////////////

// PUNTO 5: Academia de cocina
class Academia {
    const property estudiantes = []
    const property recetario = []
    
    method entrenar() {
        estudiantes.forEach { cocinero => self.entrenarCocinero(cocinero) }
    }
    
    method entrenarCocinero(cocinero) {
        const recetaOptima = self.mejorRecetaPara(cocinero)
        if (recetaOptima != null) {
            try {
                const comida = cocinero.preparar(recetaOptima)
                console.println(cocinero.nombre() + " preparó: " + comida.toString())
            } catch e : DomainException {
                console.println(cocinero.nombre() + " no pudo preparar la receta óptima")
            }
        } else {
            console.println(cocinero.nombre() + " no puede preparar ninguna receta")
        }
    }
    
    method mejorRecetaPara(cocinero) {
        const recetasDisponibles = recetario.filter { receta => 
            cocinero.nivel().puedePreparar(receta, cocinero) 
        }
        
        if (recetasDisponibles.isEmpty()) {
            return null
        }
        
        return recetasDisponibles.max { receta => receta.experienciaBase() }
    }
    
    method agregarEstudiante(cocinero) {
        estudiantes.add(cocinero)
    }
    
    method agregarReceta(receta) {
        recetario.add(receta)
    }
    
    override method toString() = "Academia con " + estudiantes.size() + " estudiantes"
}

///////////////  FACTORY PARA FACILITAR CREACIÓN ///////////////

object fabrica {
    method crearCocinero(nombre) = new Cocinero(nombre = nombre)
    
    method crearReceta(ingredientes, dificultad) = 
        new Receta(ingredientes = ingredientes, dificultad = dificultad)
    
    method crearRecetaGourmet(ingredientes, dificultad) = 
        new RecetaGourmet(ingredientes = ingredientes, dificultad = dificultad)
    
    method crearAcademia() = new Academia()
}

///////////////  EJEMPLOS DE USO ///////////////

object ejemplos {
    
    method cocineroBasico() {
        const juan = fabrica.crearCocinero("Juan")
        
        // Recetas de ejemplo
        const recetaFacil = fabrica.crearReceta(["tomate", "cebolla"], 2)
        const recetaCompleja = fabrica.crearReceta(["carne", "verduras", "especias"], 4)
        
        // Juan prepara recetas
        juan.preparar(recetaFacil)
        juan.preparar(recetaCompleja)
        
        return juan
    }
    
    method academiaCompleta() {
        const academia = fabrica.crearAcademia()
        
        // Crear estudiantes
        const maria = fabrica.crearCocinero("María")
        const carlos = fabrica.crearCocinero("Carlos") 
        const ana = fabrica.crearCocinero("Ana")
        
        academia.agregarEstudiante(maria)
        academia.agregarEstudiante(carlos)
        academia.agregarEstudiante(ana)
        
        // Agregar recetas al recetario
        academia.agregarReceta(fabrica.crearReceta(["sal", "pimienta"], 1))
        academia.agregarReceta(fabrica.crearReceta(["tomate", "cebolla", "ajo"], 3))
        academia.agregarReceta(fabrica.crearReceta(["pasta", "salsa", "queso", "albahaca"], 4))
        academia.agregarReceta(fabrica.crearRecetaGourmet(["trufa", "caviar"], 8))
        
        return academia
    }
}