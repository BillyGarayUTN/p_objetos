class Mounstro{

    var property objetosParaSerAtrapado  = []

    var property objetosPersonales = []

    method puedeSerAtrapadoPor(cazador) =
        objetosParaSerAtrapado.all{unObjeto=>cazador.objetos().contains(unObjeto)}

    method esAfectadoPor(cazador){}
    
}
                                                        // #{"hierro","sal"}
class Banshee inherits Mounstro(objetosParaSerAtrapado=["hierro","sal"]){

    override method esAfectadoPor(cazador){
        cazador.pierdeObjetos()
    }
}

class Curupi inherits Mounstro{

    override method esAfectadoPor(cazador){
        cazador.destrezaALaMitad()
    }
}

class LuzMala inherits Mounstro{

    override method esAfectadoPor(cazador){
        cazador.reduceDestreza()
    }
}

class Djinn inherits Mounstro{

    override method esAfectadoPor(cazador){
        cazador.liberarUltimoMounstro()
    }
}

class Cazador{

    var property nivelDestreza  = 0 // no puede ser cero

    method nivelDestreza(unValor) {
        if (unValor < 0) {
            nivelDestreza = 0
        } else {
            nivelDestreza = unValor
        }
    }

    var property mounstroCazado = []

    var property objetos = []

    method cazar(mounstro){
        if(mounstro.puedeSerAtrapadoPor(self)){
            mounstroCazado.add(mounstro)
        }else{
            mounstro.esAfectadoPor(self)
        }   
    }

    method debeInvestigar(caso){
        caso.investigar(self)
    }


    method quitarUltimoObjeto(){
        objetos.removeLast()
    }

    method agregarObjeto(unObjeto){
        objetos.add(unObjeto)
    }


    method pierdeObjetos(){
        self.objetos().clear()
    }

    method destrezaALaMitad(){
        self.nivelDestreza(self.nivelDestreza() / 2)
    }

    method reduceDestreza(){
        self.nivelDestreza(self.nivelDestreza() - self.objetos().size())
    }

    method liberarUltimoMounstro(){
        mounstroCazado.removeLast()
        nivelDestreza += 1
    }

    method agregarNivelDestreza(unNivel){
        nivelDestreza += unNivel
    }

    method cumple(criterioAceptacion) =
        criterioAceptacion.apply(self)
        // cazador=>cazador.mounstroCazado() >= 10

    method destrezaSuperior()= self.nivelDestreza() > 1000
    
}

//////////////////////////   CASOS  ////////////////////////

class Crimen{
    const objeto

    method investigar(cazador){
        cazador.agregarObjeto(objeto)
    }
}

class Trampa{
    
    method investigar(cazador){
        cazador.quitarUltimoObjeto()
    }
}

class Avistaje{
    const puntosExtra

    method investigar(cazador){
        cazador.agregarNivelDestreza(puntosExtra)
    }
}



//////////////////////////   CONCURSO  ////////////////////////

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
    

// Punto 5 //

class Kraken inherits Mounstro{

    override method puedeSerAtrapadoPor(cazador) = super(cazador) && cazador.destrezaSuperior()
}

/*
class Mounstro{

    var property objetosParaSerAtrapado  = []

    var property objetosPersonales = []

    method puedeSerAtrapadoPor(cazador) =
        objetosParaSerAtrapado.all{unObjeto=>cazador.objetos().contains(unObjeto)}

    method esAfectadoPor(cazador){}
    
}


*/