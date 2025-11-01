


class CamposAbiertos{
    const tamanio // en metros cuadrados
    const riquezaMineral // es un numero
    var property cultivos = []

    method costoMantenimiento() = 500 * tamanio
    
    method capacidadMaxima() = tamanio * 4 // 4 plantas por m2
    
    method tieneAireLibre() = true
    
    method agregarCultivo(cultivo) {
        if(cultivos.size() < self.capacidadMaxima() && cultivo.puedePlantarseEn(self)) {
            cultivos.add(cultivo)
        } else {
            self.error("No se puede plantar este cultivo")
        }
    }
    
    method esRico() = riquezaMineral > 100
    
    method mediaNutricional() {
        if(cultivos.isEmpty()) {
            return 0
        } else {
            return cultivos.sum({ cultivo => cultivo.valorNutricional(self) }) / cultivos.size()
        }
    }
    
    method valorNeto() = cultivos.sum({ cultivo => cultivo.precioVenta(self) }) - self.costoMantenimiento()
}

class Invernadero{
    var dispositivo // dispositivo instalado
    var property cultivos = []
    
    method costoMantenimiento() = 50000 + dispositivo.mantenimiento()
    
    var property capacidadMaxima // se construye a medida

    method tieneAireLibre() = false
    
    method cambiarDispositivo(nuevoDispositivo) {
        dispositivo = nuevoDispositivo
    }
    
    method agregarCultivo(cultivo) {
        if(cultivos.size() < capacidadMaxima && cultivo.puedePlantarseEn(self)) {
            cultivos.add(cultivo)
        } else {
            self.error("No se puede plantar este cultivo")
        }
    }
    
    method esRico() = cultivos.size() < (capacidadMaxima / 2) || dispositivo.esRico()
    
    method mediaNutricional() {
        if(cultivos.isEmpty()) {
            return 0
        } else {
            return cultivos.sum({ cultivo => cultivo.valorNutricional(self) }) / cultivos.size()
        }
    }
    
    method valorNeto() = cultivos.sum({ cultivo => cultivo.precioVenta(self) }) - self.costoMantenimiento()
}


////////////////////   DISPOSITIVOS   ////////////////////
class ReguladorNutricional{

    method mantenimiento() = 2000 
    
    method esRico()= true
}

class Humidificador{
    const configuracion // configuracion tiene que ser un valor entre 0 y 100

    method mantenimiento() = if(configuracion > 30) 4500 else 1000

    method esRico() = configuracion < 40 && configuracion >20
}

class PanelesSolares{

    method mantenimiento() = -25000

    method esRico() = false
}

class Papa{
    method puedePlantarseEn(terreno) = true

    method valorNutricional(terreno) = if(terreno.esRico()) 3000 else 1500

    method precioVenta(terreno) = self.valorNutricional(terreno) / 2
}

class Algodon{
    method puedePlantarseEn(terreno) = terreno.esRico()

    method valorNutricional(terreno) = 0

    method precioVenta(terreno) = 500
}

class ArbolFrutal{
    const fruta
    const edad

    method puedePlantarseEn(terreno) = terreno.tieneAireLibre()

    method valorNutricional(terreno) = (3 * edad).min(4000)

    method precioVenta(terreno) = fruta.precioVenta()
}

// Ejemplo de clase Fruta
class Fruta{
    var property precioVenta
}


class Palmeras inherits ArbolFrutal{

    override method puedePlantarseEn(terreno) = terreno.esRico()

    override method precioVenta(terreno) = super(terreno) * 5

    override method valorNutricional(terreno) = (2*edad).min(7500)
}