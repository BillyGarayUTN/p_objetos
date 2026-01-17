// ============ ACADEMIA DE COCINA ============
// Solución con POLIMORFISMO

///////////////  COCINERO ///////////////

class Cocinero {
    const property nombre
    var property nivel = new Principiante()  // Todos empiezan como principiantes
    const property preparaciones = []  // Lista de comidas preparadas
    
    // Experiencia total acumulada
    method experiencia() = preparaciones.sum { comida => comida.experienciaQueAporta() }
    
    // Preparar una receta
    method prepara(receta) {
        // El nivel decide si puede preparar y con qué calidad
        if (!nivel.puedePreparar(receta, self)) {
            throw new DomainException(message = nombre + " no puede preparar esta receta con su nivel actual")
        }
        
        const comida = nivel.prepararComida(receta, self)
        preparaciones.add(comida)
        
        // Verificar si debe cambiar de nivel
        if (nivel.superoNivel(self)) {
            nivel = nivel.siguienteNivel()
        }
        
        return comida
    }
    
    // Métodos auxiliares para que los niveles consulten
    method comidasDificiles() = preparaciones.count { comida => comida.receta().esDificil() }
    
    method preparacionesSimilaresA(receta) = 
        preparaciones.filter { comida => comida.receta().esSimilarA(receta) }
    
    method experienciaEnRecetasSimilaresA(receta) = 
        self.preparacionesSimilaresA(receta).sum { comida => comida.experienciaQueAporta() }
    
    method cantidadComidasSimilaresA(receta) = self.preparacionesSimilaresA(receta).size()
    
    override method toString() = nombre + " (Nivel: " + nivel.nombre() + ", Exp: " + self.experiencia() + ")"
}

///////////////  NIVELES DE APRENDIZAJE (POLIMORFISMO) ///////////////

class Nivel {
    // Interfaz polimórfica - cada nivel la implementa a su manera
    method puedePreparar(receta, cocinero)
    method prepararComida(receta, cocinero)
    method superoNivel(cocinero)
    method siguienteNivel()
    method nombre()
}

// ===== PRINCIPIANTE =====
class Principiante inherits Nivel {
    
    // Solo puede preparar recetas NO difíciles
    override method puedePreparar(receta, cocinero) = !receta.esDificil()
    
    // Prepara comidas de calidad pobre o normal (nunca superior)
    override method prepararComida(receta, cocinero) {
        const calidad = if (receta.ingredientes().size() < 4) normal else pobre
        return new Comida(receta = receta, calidad = calidad)
    }
    
    // Supera el nivel con más de 100 de experiencia
    override method superoNivel(cocinero) = cocinero.experiencia() > 100
    
    override method siguienteNivel() = new Experimentado()
    
    override method nombre() = "Principiante"
}

// ===== EXPERIMENTADO =====
class Experimentado inherits Nivel {
    
    // Puede preparar recetas NO difíciles, o difíciles si son similares a alguna que ya preparó
    override method puedePreparar(receta, cocinero) = 
        !receta.esDificil() || self.conoceRecetaSimilar(receta, cocinero)
    
    method conoceRecetaSimilar(receta, cocinero) = 
        cocinero.preparacionesSimilaresA(receta).size() > 0
    
    // Puede preparar comidas de calidad normal o superior
    override method prepararComida(receta, cocinero) {
        // Si perfeccionó la receta (tiene suficiente experiencia en similares), hace superior
        if (self.perfeccionoReceta(receta, cocinero)) {
            const plus = cocinero.cantidadComidasSimilaresA(receta) / 10
            return new Comida(receta = receta, calidad = superior, plus = plus)
        } else {
            return new Comida(receta = receta, calidad = normal)
        }
    }
    
    // Perfeccionó si tiene 3 veces la experiencia base en recetas similares
    method perfeccionoReceta(receta, cocinero) {
        const experienciaRequerida = receta.experienciaBase() * 3
        return cocinero.experienciaEnRecetasSimilaresA(receta) >= experienciaRequerida
    }
    
    // Supera el nivel con más de 5 comidas difíciles preparadas
    override method superoNivel(cocinero) = cocinero.comidasDificiles() > 5
    
    override method siguienteNivel() = new Chef()
    
    override method nombre() = "Experimentado"
}

// ===== CHEF (NIVEL MÁXIMO) =====
class Chef inherits Experimentado {
    
    // Puede preparar CUALQUIER receta
    override method puedePreparar(receta, cocinero) = true
    
    // No se puede superar el nivel chef (es el máximo)
    override method superoNivel(cocinero) = false
    
    override method siguienteNivel() {
        throw new DomainException(message = "Chef es el nivel máximo")
    }
    
    override method nombre() = "Chef"
}

///////////////  RECETAS ///////////////

class Receta {
    const property ingredientes = []  // Lista de ingredientes
    const property dificultad  // Nivel de dificultad (número)
    
    // Es difícil si tiene dificultad > 5 o más de 10 ingredientes
    method esDificil() = dificultad > 5 || ingredientes.size() > 10
    
    // Dos recetas son similares si tienen los mismos ingredientes 
    // o una dificultad de no más de 1 punto de diferencia
    method esSimilarA(otraReceta) = 
        self.mismoIngredientes(otraReceta) || self.dificultadSimilar(otraReceta)
    
    method mismoIngredientes(otraReceta) = ingredientes == otraReceta.ingredientes()
    
    method dificultadSimilar(otraReceta) = (dificultad - otraReceta.dificultad()).abs() <= 1
    
    // Experiencia base que aporta la receta (sin considerar calidad)
    method experienciaBase() = ingredientes.size() * dificultad
}

///////////////  COMIDAS PREPARADAS ///////////////

class Comida {
    const property receta
    const property calidad  // Objeto polimórfico: pobre, normal o superior
    var property plus = 0   // Experiencia extra para comidas superiores
    
    method experienciaQueAporta() = calidad.experienciaQueAporta(receta, plus)
}

///////////////  CALIDADES (OBJETOS POLIMÓRFICOS) ///////////////

object pobre {
    method experienciaQueAporta(receta, plus) = receta.experienciaBase().min(4)
}

object normal {
    method experienciaQueAporta(receta, plus) = receta.experienciaBase()
}

object superior {
    method experienciaQueAporta(receta, plus) = receta.experienciaBase() + plus
}

class RecetaGourmet inherits Receta {
    // Las recetas gourmet son siempre difíciles
    override method esDificil() = true

    override method experienciaBase() = super() * 2

}

class Academia {
    var property estudiantes = []
    var property recetario = []

    // Entrenar a todos los estudiantes con sus mejores recetas
    method entrenar() {
        estudiantes.forEach { cocinero => self.entrenarCocinero(cocinero) }
    }
    
    // Entrenar a un cocinero específico
    method entrenarCocinero(cocinero) {
        const recetaOptima = self.mejorRecetaPara(cocinero)
        
        if (recetaOptima != null) {
            cocinero.prepara(recetaOptima)
        }
    }
    
    // Encontrar la receta que más experiencia aporta de las que puede preparar
    method mejorRecetaPara(cocinero) {
        const recetasDisponibles = recetario.filter { receta => 
            cocinero.nivel().puedePreparar(receta, cocinero) 
        }
        
        if (recetasDisponibles.isEmpty()) {
            return null
        }
        
        return recetasDisponibles.max { receta => receta.experienciaBase() }
    }

}


