class NoSePuedePlantar inherits Exception{}

class ExcedeMaximaPlantacion inherits Exception{}

// Terrenos //
class Terreno{
    var property cultivos = []

    method costoMantenimiento()

    var property maxPlantacion
    // punto 1
    method esRico()

    // punto 2
    method mediaNutricional() = if(cultivos.isEmpty()) 0 else cultivos.sum{uno=>uno.valorNutricional(self)} / cultivos.size()

    // punto 3
    method valorNeto() = cultivos.sum{uno=>uno.venta(self)} - self.costoMantenimiento() 

    method lugarAbierto() = false

    // punto 4
    method agregarCultivo(cultivo){
        if(!cultivo.puedePlantarseEn(self)){
            throw new NoSePuedePlantar ( message = "No se puede plantar en este terreno")
        }

        if(maxPlantacion == cultivos.size()){
            throw new ExcedeMaximaPlantacion ( message = "No se puede Plantar excede el maximo de plantacion")

        }
        
        cultivos.add(cultivo)
    }

}
class CamposAbiertos inherits Terreno{

    const tamanio

    const riquezaMineral

    override method maxPlantacion() = 4 * tamanio

    override method costoMantenimiento() = 500 * tamanio  // $500 por m²

    override method esRico() = riquezaMineral > 100 

    override method lugarAbierto() = true
}   

class Invernaderos inherits Terreno{

    var property dispositivo

    override method costoMantenimiento() = 50000 + dispositivo.costoMantenimiento()  // Base $50,000
    
    override method esRico() = (cultivos.size() < (maxPlantacion / 2)) || dispositivo.esRico()  // NO alcanzan la mitad
}

// Dispositivos //
class ReguladoresNutricionales{ 

    method costoMantenimiento() = 2000  // Corregido typo

    method esRico() = true
}

class Humificadores{
    const humedad

    method costoMantenimiento() = if(humedad <= 30) 1000 else 4500  // ≤30% es más barato

    method esRico() = humedad.between(20,40)
}

class PanelesSolares{

    method costoMantenimiento() = -25000  // Ahorro de $25,000

    method esRico() = false
}

// Cultivos //

class Papa{ 

    method valorNutricional(terreno) = if(terreno.esRico()) 3000 else 1500

    method venta(terreno) = self.valorNutricional(terreno) / 2

    method puedePlantarseEn(terreno) = true
    // puede plantarse en cualquier terreno
}   

class Algodon{

    method valorNutricional(terreno) = 0

    method venta(terreno) = 500

    method puedePlantarseEn(terreno) = terreno.esRico()
    //solo puede plantarse en terreno rico
}

class ArbolFrutal{
    const edad

    var property fruta

    method valorNutricional(terreno) = (3 * edad).min(4000)  

    method venta(terreno) = fruta.precio()  // Depende del precio de la fruta

    method puedePlantarseEn(terreno) = terreno.lugarAbierto()
    // Solo pueden ser plantados en Campo Abierto
}
// punto 5
class Palmera inherits ArbolFrutal{
    
    override method valorNutricional(terreno) = (edad * 2).min(7500) 
    
    override method puedePlantarseEn(terreno) = terreno.esRico() && super(terreno)  // Rico Y campo abierto

    override method venta(terreno) = super(terreno) * 5  
}

// Clase Fruta (necesaria para ArbolFrutal)
class Fruta {
    const property precio
}