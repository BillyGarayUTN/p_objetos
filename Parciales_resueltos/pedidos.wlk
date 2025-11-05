// Sistema de Delivery

class Cliente {
    var property nombre
    var property dni
    var property historialCompras = []
    var property tipo
    var property direccion
    
    method realizarCompra(compra) {
        historialCompras.add(compra)
    }
    
    method cantidadCompras() = historialCompras.size()
    
    // PUNTO 4: Compra más cara
    method compraMasCara() {
        if (historialCompras.isEmpty()) {
            self.error("El cliente no tiene compras realizadas")
        }
        return historialCompras.max { compra => compra.precioTotal() }
    }
    
    // PUNTO 5: Monto total ahorrado
    method montoTotalAhorrado() = 
        historialCompras.sum { compra => self.ahorroEnCompra(compra) }
    
    method ahorroEnCompra(compra) {
        const costoReal = compra.pedido().costoEnvioReal(self)
        const costoPagado = compra.valorEnvio()
        return costoReal - costoPagado
    }
    
    // PUNTO 6a: Producto más caro comprado (precio unitario)
    method productoMasCaro() = 
        self.todosLosItems().maxBy { item => item.producto().precio() }.producto()
    
    // PUNTO 6b: Producto con mayor cantidad en un mismo pedido
    method productoMayorCantidad() = 
        self.todosLosItems().maxBy { item => item.cantidad() }.producto()
    
    // Método auxiliar para no repetir lógica
    method todosLosItems() = 
        historialCompras.flatMap { compra => compra.pedido().items() }
}

/////////////  TIPOS DE CLIENTE /////////////

class Comun {
    method porcentajeEnvio(cliente) = 1.0  // Paga el 100%
}

class Silver {
    method porcentajeEnvio(cliente) = 0.5  // Paga el 50%
}

class Gold {
    
    method porcentajeEnvio(cliente) = 
        if (self.tieneEnvioGratis(cliente)) 0.0 else 0.1  // 0% o 10%
    
    method tieneEnvioGratis(cliente) = cliente.cantidadCompras() % 5 == 0
}

///////////////  PEDIDO ///////////////

class Pedido {
    var property items = []
    var property local
    
    // PUNTO 1: Precio bruto (sin considerar cliente ni envío)
    method precioBruto() = items.sum { item => item.subtotal() }
    
    // Precio neto (bruto + envío con descuentos)
    method precioNeto(cliente) = self.precioBruto() + self.costoEnvio(cliente)
    
    // Punto 2 b
    // Costo de envío según tipo de cliente
    method costoEnvio(cliente) =
        self.costoEnvioReal(cliente) * cliente.tipo().porcentajeEnvio(cliente)
    
    
    // Punto 2 a
    // Costo real del envío (15 por cuadra, máximo 300)
    method costoEnvioReal(cliente) {
        const distancia = calculadorDeCuadras.distancia(cliente, local)
        return (distancia * 15).min(300)
    }

    method agregarItem(producto, cantidad) {
        const itemExistente = items.find{ item => item.producto() == producto }
        if (itemExistente != null) {
            // Camino A: incrementar cantidad existente
            itemExistente.agregarCantidad(cantidad)
        } else {
            // Camino B: crear nuevo ítem
            const nuevoItem = new Item(producto = producto, cantidad = cantidad)
            items.add(nuevoItem)
        }
    }
    
    method productos() = items.map { item => item.producto() }.asSet()
    
    method realizarCompra(cliente) {
        if (local.tieneTodosLosProductos(self)) {
            const compra = new Compra(
                pedido = self,
                cliente = cliente,
                valorEnvio = self.costoEnvio(cliente),
                fecha = new Date()
            )
            cliente.realizarCompra(compra)
            return compra
        } else {
            self.error("El local no tiene todos los productos disponibles")
        }
    }
}

class Item {
    var property producto
    var property cantidad
    
    method subtotal() = producto.precio() * cantidad
    
    method agregarCantidad(cantidadExtra) {
        cantidad += cantidadExtra
    }
}

class Producto {
    var property nombre
    var property precio
    
}

class Local {
    var property nombre
    var property direccion
    var property productosDisponibles = #{}  // Set de productos en stock
    
    method tieneProducto(producto) = productosDisponibles.contains(producto)
    
    method tieneTodosLosProductos(pedido) = 
        pedido.productos().all { producto => self.tieneProducto(producto) }
}

// Calculador de distancias (módulo externo)
object calculadorDeCuadras {
    method distancia(cliente, local) {
        // Implementación externa - solo interfaz
        return 10  // Valor por defecto para testing
    }
}

///////////////  COMPRA ///////////////

class Compra {
    const property pedido
    const property cliente
    const property valorEnvio
    const property fecha
    
    method precioTotal() = pedido.precioBruto() + valorEnvio
}

