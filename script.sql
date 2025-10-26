-- ======================================================
--  BASE DE DATOS: mrfrito
-- ======================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, 
    SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,
    ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
--  SCHEMA
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mrfrito` DEFAULT CHARACTER SET utf8mb4;
USE `mrfrito`;

-- ======================================================
--  TABLA: canales
-- ======================================================
CREATE TABLE IF NOT EXISTS `canales` (
  `id_canal` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `porcentaje_comision` DECIMAL(5,2) DEFAULT 0,
  `descripcion` VARCHAR(255) NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modificacion` DATETIME NULL,
  `estado` ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
  PRIMARY KEY (`id_canal`)
) ENGINE = InnoDB;

-- ======================================================
--  TABLA: ventas
-- ======================================================
CREATE TABLE IF NOT EXISTS `ventas` (
  `id_venta` INT NOT NULL AUTO_INCREMENT,
  `id_canal` INT NOT NULL,
  `fecha` DATETIME NOT NULL,
  `monto_total` DECIMAL(10,2) NOT NULL,
  `comision` DECIMAL(10,2) GENERATED ALWAYS AS (monto_total * (SELECT porcentaje_comision/100 FROM canales c WHERE c.id_canal = ventas.id_canal)) STORED,
  `monto_neto` DECIMAL(10,2) GENERATED ALWAYS AS (monto_total - comision) STORED,
  `descripcion` VARCHAR(255) NULL,
  `estado` ENUM('activa','anulada') NOT NULL DEFAULT 'activa',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modificacion` DATETIME NULL,
  PRIMARY KEY (`id_venta`),
  INDEX `idx_fecha` (`fecha` ASC),
  CONSTRAINT `fk_ventas_canales`
    FOREIGN KEY (`id_canal`)
    REFERENCES `canales` (`id_canal`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ======================================================
--  TABLA: categorias_gasto
-- ======================================================
CREATE TABLE IF NOT EXISTS `categorias_gasto` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `tipo` ENUM('fijo','variable') NOT NULL,
  `descripcion` VARCHAR(255) NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE = InnoDB;

-- ======================================================
--  TABLA: gastos
-- ======================================================
CREATE TABLE IF NOT EXISTS `gastos` (
  `id_gasto` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `descripcion` VARCHAR(255) NULL,
  `monto` DECIMAL(10,2) NOT NULL,
  `comprobante` VARCHAR(100) NULL,
  `estado` ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modificacion` DATETIME NULL,
  PRIMARY KEY (`id_gasto`),
  INDEX `idx_fecha_creacion` (`fecha_creacion` ASC),
  INDEX `fk_gastos_categorias_gasto_idx` (`id_categoria` ASC),
  CONSTRAINT `fk_gastos_categorias_gasto`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `categorias_gasto` (`id_categoria`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ======================================================
--  TABLA: presupuestos
-- ======================================================
CREATE TABLE IF NOT EXISTS `presupuestos` (
  `id_presupuesto` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `fecha_inicio` DATE NOT NULL,
  `fecha_fin` DATE NOT NULL,
  `monto_planificado` DECIMAL(10,2) NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modificacion` DATETIME NULL,
  `estado` ENUM('vigente','cerrado') NOT NULL DEFAULT 'vigente',
  `mes` TINYINT GENERATED ALWAYS AS (MONTH(fecha_inicio)) STORED,
  `anio` YEAR GENERATED ALWAYS AS (YEAR(fecha_inicio)) STORED,
  PRIMARY KEY (`id_presupuesto`),
  INDEX `idx_fecha_inicio` (`fecha_inicio` ASC),
  INDEX `fk_presupuestos_categorias_gasto_idx` (`id_categoria` ASC),
  CONSTRAINT `fk_presupuestos_categorias_gasto`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `categorias_gasto` (`id_categoria`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ======================================================
--  TABLA: alertas
-- ======================================================
CREATE TABLE IF NOT EXISTS `alertas` (
  `id_alerta` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `fecha_alerta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `descripcion` VARCHAR(255) NOT NULL,
  `estado` ENUM('activa','leida','resuelta') NOT NULL DEFAULT 'activa',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modificacion` DATETIME NULL,
  PRIMARY KEY (`id_alerta`),
  INDEX `fk_alertas_categorias_gasto_idx` (`id_categoria` ASC),
  CONSTRAINT `fk_alertas_categorias_gasto`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `categorias_gasto` (`id_categoria`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ======================================================
--  VISTA: resumen_mensual
-- ======================================================
CREATE OR REPLACE VIEW `resumen_mensual` AS
SELECT
  YEAR(v.fecha) AS anio,
  MONTH(v.fecha) AS mes,
  SUM(v.monto_total) AS total_ventas,
  SUM(v.comision) AS total_comisiones,
  SUM(v.monto_neto) AS ventas_netas,
  IFNULL((
    SELECT SUM(g.monto)
    FROM gastos g
    WHERE YEAR(g.fecha_creacion) = YEAR(v.fecha)
      AND MONTH(g.fecha_creacion) = MONTH(v.fecha)
  ), 0) AS total_gastos,
  (
    SUM(v.monto_neto) -
    IFNULL((
      SELECT SUM(g.monto)
      FROM gastos g
      WHERE YEAR(g.fecha_creacion) = YEAR(v.fecha)
        AND MONTH(g.fecha_creacion) = MONTH(v.fecha)
    ), 0)
  ) AS utilidad
FROM ventas v
GROUP BY anio, mes
ORDER BY anio DESC, mes DESC;

-- ======================================================
--  DATOS DE EJEMPLO
-- ======================================================
INSERT INTO canales (nombre, porcentaje_comision, descripcion)
VALUES 
('Tienda', 0, 'Ventas directas en restaurante'),
('Delivery', 5, 'Comisión por servicio de entrega'),
('Plataforma', 10, 'Comisión por venta en PedidosYa');

INSERT INTO categorias_gasto (nombre, tipo, descripcion)
VALUES
('Alquiler', 'fijo', 'Pago mensual de renta del local'),
('Servicios', 'fijo', 'Luz, agua, internet, teléfono'),
('Insumos', 'variable', 'Ingredientes y materia prima'),
('Empaques', 'variable', 'Cajas, bolsas y envoltorios');

-- ======================================================
--  RESTAURAR CONFIGURACIONES
-- ======================================================
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
