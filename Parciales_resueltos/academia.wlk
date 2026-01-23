// ============ ACADEMIA DE COCINA ============

class Receta{
    var property ingredientes = []

    var nivelDificultad

    method esDificil() = nivelDificultad > 5 || ingredientes.size() >10

    method esSimiliar(otraReceta) = 
        ingredientes == otraReceta.ingredientes() || 
        (nivelDificultad - otraReceta.nivelDificultad()).abs() <= 1

}

class Cocinero{
    var property comidas = []  

    method prepararReceta(receta) {
        if (nivel.puedePreparar(receta,self)) {
        // Aquí nace la comida
            const nuevaComida = new Comida(receta= receta,calidad=nivel.elaboraComida(self))
            comidas.add(nuevaComida)
        }
    }

    method experiencia() = comidas.sum({ c => c.experienciaAporta() })

    var property nivel 
}

class Comida{
    var property receta

    var calidad 

    var property experienciaAporta = calidad.experiencia()
}

// class calidad de comida

class Pobre{
    method experiencia() = 1
}
class Normal{
    method experiencia() = 3
}

class Superior{
    method experiencia() = 5
}
// class calidad de comida
// pobre
// normal
// superior


// niveles
// principiante
// experimentado
// chef
class Principiante{
    method elaboraComida(cocinero) = new Normal()

    method puedePreparar(receta,cocinero) = !receta.esDificil()

}
class Experimentado{
    method elaboraComida(cocinero) = if(cocinero.experiencia() >20)  new Superior() else new Normal()

    method puedePreparar(receta,cocinero) = !receta.esDificil() || cocinero.comidas().any{un=>receta.esSimilar(un.receta())}

}

class Chef inherits Experimentado{
    override method elaboraComida(cocinero) = new Superior()

    override method puedePreparar(receta,cocinero) = true
}