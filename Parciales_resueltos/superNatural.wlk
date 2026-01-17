class Mounstro{
    var property objetosParaSerAtrapado = []

    method daniaA(cazador){}

}

class Banshee inherits Mounstro{
    override method daniaA(cazador) = cazador.pierdeTodosObjetos()
}

class Curupi  inherits Mounstro{
    override method daniaA(cazador) = cazador.destrezaALaMitad() 
}

class LuzMala inherits Mounstro{
    override method daniaA(cazador) = cazador.reduceDestrezaSegunCantObjetos()
}

class Djinn inherits Mounstro{
    override method daniaA(cazador) = cazador.liberaUltimoMounstro()
}

class Cazador{
    var property mounstrosCazados = []
    var property objetosObtenidos = []
    var property nivelDestreza

    method gana(mounstro) = 
        if(self.tieneTodosLosObjetos(mounstro)){
            mounstrosCazados.add(mounstro)
        }else {
            mounstro.daniaA(self)
        }

    method tieneTodosLosObjetos(mounstro) = 
        mounstro.objetosParaSerAtrapado().all { obj => objetosObtenidos.contains(obj) }

    method pierdeTodosObjetos() { self.objetosObtenidos().clear() }

    method destrezaALaMitad() { nivelDestreza = nivelDestreza / 2}

    method reduceDestrezaSegunCantObjetos() { nivelDestreza = (nivelDestreza - objetosObtenidos.size()).max(0) }

    method liberaUltimoMounstro() { 
        mounstrosCazados.remove(mounstrosCazados.last()) 
        nivelDestreza = nivelDestreza + 1 }

    method investiga(caso) = caso.esInvestigadoPor(self)

    method agregaPuntosDestreza(puntos) {
        nivelDestreza = nivelDestreza + puntos} 

    method liberaUltimoObjeto() { 
        objetosObtenidos.remove(objetosObtenidos.last())}

    method agregarObjeto(objeto) {
        objetosObtenidos.add(objeto)}

    // Métodos para el concurso
    method cantidadMonstruosCazados() = mounstrosCazados.size()

    method monstruoMasJodido() {
        if (mounstrosCazados.isEmpty()) {
            throw new Exception(message = "No ha cazado ningún monstruo")
        }
        return mounstrosCazados.max { monstruo => monstruo.objetosParaSerAtrapado().size() }
    }

    method cantidadMonstruosDeUnObjeto() = 
        mounstrosCazados.count { monstruo => monstruo.objetosParaSerAtrapado().size() == 1 }

    method cumple(criterioAceptacion) =
        criterioAceptacion.apply(self)
        // cazador=>cazador.mounstroCazado() >= 10

    method destrezaSuperior() = nivelDestreza >1000
}

// Casos //

class Crimen{
    var property objetoExpuesto

    method esInvestigadoPor(cazador) = cazador.agregarObjeto(objetoExpuesto)
}

class Trampa{
    method esInvestigadoPor(cazador) = cazador.liberaUltimoObjeto()
}

class Avistaje{
    var property puntosExtra

    method esInvestigadoPor(cazador) = cazador.agregaPuntosDestreza(puntosExtra)  
}

class Concurso{

    const criterioValoracion
    const criterioAceptacion

    var property cazadoresParticipantes = []

    method podio() = 
        self.cazadoresParticipantes().sortedBy{un,otro=>criterioValoracion.apply(un) >criterioValoracion.apply(otro)}.take(3)

    method registrar(cazador){
        self.validar(cazador)
        cazadoresParticipantes.add(cazador)
    }

    method validar(cazador){
        if(!cazador.cumple(criterioAceptacion)){
            throw "Cazador no cumple con los requisitos para participar"
        }
    }

}

// criterios de valoracion
const criterioDeMayorCazadoresMounstros = {cazador=>cazador.cantidadDeMounstrosCazados() }

//  criterio de aceptacion
const criterioDeCantidadMounstro = {cazador=>cazador.mounstroCazado() >= 10 }


// Creacion de Concurso " El Rambo Guarani"
const concursoElRamboGuarani = new Concurso(   
    criterioValoracion= criterioDeMayorCazadoresMounstros,
    criterioAceptacion= criterioDeCantidadMounstro)

// punto  5

class Kraken inherits Mounstro{
    override method daniaA(cazador) = super(cazador) && cazador.destrezaSuperior()
}