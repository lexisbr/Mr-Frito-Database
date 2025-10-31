-- ======================================================
--  BASE DE DATOS: mrfrito
-- ======================================================

CREATE SCHEMA IF NOT EXISTS `mrfrito` DEFAULT CHARACTER SET utf8mb4;
USE `mrfrito`;

-- ======================================================
--  TABLAS PRINCIPALES
-- ======================================================

CREATE TABLE IF NOT EXISTS `usuarios` (
  `id_user` INT NOT NULL AUTO_INCREMENT,
  `nombres` VARCHAR(100) NOT NULL,
  `apellidos` VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `user_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(191) NOT NULL,
  `role` ENUM('USER','ADMIN') NOT NULL DEFAULT 'ADMIN',
  `usuario_creacion` INT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_modificacion` INT NOT NULL,
  `fecha_modificacion` DATETIME NULL,
  `estado` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id_user`),
  UNIQUE INDEX `idx_user_name` (`user_name` ASC),
  UNIQUE INDEX `idx_email` (`email` ASC),
  INDEX `idx_estado` (`estado` ASC)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `canales` (
  `id_canal` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `porcentaje_comision` DECIMAL(5,2) DEFAULT 0,
  `descripcion` VARCHAR(255) NULL,
  `usuario_creacion` INT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_modificacion` INT NOT NULL,
  `fecha_modificacion` DATETIME NULL,
  `estado` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id_canal`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `ventas` (
  `id_venta` INT NOT NULL AUTO_INCREMENT,
  `id_canal` INT NOT NULL,
  `fecha` DATETIME NOT NULL,
  `monto_total` DECIMAL(10,2) NOT NULL,
  `comision` DECIMAL(10,2) DEFAULT 0,
  `monto_neto` DECIMAL(10,2) DEFAULT 0,
  `descripcion` VARCHAR(255) NULL,
  `usuario_creacion` INT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_modificacion` INT NOT NULL,
  `fecha_modificacion` DATETIME NULL,
  `estado` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id_venta`),
  INDEX `idx_fecha` (`fecha` ASC),
  CONSTRAINT `fk_ventas_canales`
    FOREIGN KEY (`id_canal`) REFERENCES `canales` (`id_canal`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `categorias_gasto` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `tipo` ENUM('fijo','variable') NOT NULL,
  `descripcion` VARCHAR(255) NULL,
  `usuario_creacion` INT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_modificacion` INT NOT NULL,
  `fecha_modificacion` DATETIME NULL,
  `estado` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id_categoria`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `gastos` (
  `id_gasto` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `descripcion` VARCHAR(255) NULL,
  `monto` DECIMAL(10,2) NOT NULL,
  `comprobante` VARCHAR(100) NULL,
  `usuario_creacion` INT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_modificacion` INT NOT NULL,
  `fecha_modificacion` DATETIME NULL,
  `estado` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id_gasto`),
  INDEX `idx_fecha_creacion` (`fecha_creacion` ASC),
  INDEX `fk_gastos_categorias_gasto_idx` (`id_categoria` ASC),
  CONSTRAINT `fk_gastos_categorias_gasto`
    FOREIGN KEY (`id_categoria`) REFERENCES `categorias_gasto` (`id_categoria`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `presupuestos` (
  `id_presupuesto` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `fecha_inicio` DATE NOT NULL,
  `fecha_fin` DATE NOT NULL,
  `monto_planificado` DECIMAL(10,2) NOT NULL,
  `usuario_creacion` INT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_modificacion` INT NOT NULL,
  `fecha_modificacion` DATETIME NULL,
  `estado` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id_presupuesto`),
  INDEX `idx_fecha_inicio` (`fecha_inicio` ASC),
  INDEX `fk_presupuestos_categorias_gasto_idx` (`id_categoria` ASC),
  CONSTRAINT `fk_presupuestos_categorias_gasto`
    FOREIGN KEY (`id_categoria`) REFERENCES `categorias_gasto` (`id_categoria`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `alertas` (
  `id_alerta` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `fecha_alerta` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `descripcion` VARCHAR(255) NOT NULL,
  `notificacion_abierta` TINYINT DEFAULT 0,
  `usuario_creacion` INT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_modificacion` INT NOT NULL,
  `fecha_modificacion` DATETIME NULL,
  `estado` TINYINT(1) DEFAULT 1,
  PRIMARY KEY (`id_alerta`),
  INDEX `fk_alertas_categorias_gasto_idx` (`id_categoria` ASC),
  CONSTRAINT `fk_alertas_categorias_gasto`
    FOREIGN KEY (`id_categoria`) REFERENCES `categorias_gasto` (`id_categoria`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ======================================================
--  TABLAS LOG
-- ======================================================

CREATE TABLE IF NOT EXISTS `log_canales` (
  `id_log` INT AUTO_INCREMENT PRIMARY KEY,
  `id_canal` INT,
  `accion` ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `campo_modificado` VARCHAR(100),
  `valor_anterior` VARCHAR(255),
  `valor_nuevo` VARCHAR(255),
  `fecha_log` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `usuario` VARCHAR(50) DEFAULT 'sistema',
  FOREIGN KEY (`id_canal`) REFERENCES `canales` (`id_canal`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `log_ventas` (
  `id_log` INT AUTO_INCREMENT PRIMARY KEY,
  `id_venta` INT,
  `accion` ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `campo_modificado` VARCHAR(100),
  `valor_anterior` VARCHAR(255),
  `valor_nuevo` VARCHAR(255),
  `fecha_log` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `usuario` VARCHAR(50) DEFAULT 'sistema',
  FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `log_categorias_gasto` (
  `id_log` INT AUTO_INCREMENT PRIMARY KEY,
  `id_categoria` INT,
  `accion` ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `campo_modificado` VARCHAR(100),
  `valor_anterior` VARCHAR(255),
  `valor_nuevo` VARCHAR(255),
  `fecha_log` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `usuario` VARCHAR(50) DEFAULT 'sistema',
  FOREIGN KEY (`id_categoria`) REFERENCES `categorias_gasto` (`id_categoria`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `log_gastos` (
  `id_log` INT AUTO_INCREMENT PRIMARY KEY,
  `id_gasto` INT,
  `accion` ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `campo_modificado` VARCHAR(100),
  `valor_anterior` VARCHAR(255),
  `valor_nuevo` VARCHAR(255),
  `fecha_log` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `usuario` VARCHAR(50) DEFAULT 'sistema',
  FOREIGN KEY (`id_gasto`) REFERENCES `gastos` (`id_gasto`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `log_presupuestos` (
  `id_log` INT AUTO_INCREMENT PRIMARY KEY,
  `id_presupuesto` INT,
  `accion` ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `campo_modificado` VARCHAR(100),
  `valor_anterior` VARCHAR(255),
  `valor_nuevo` VARCHAR(255),
  `fecha_log` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `usuario` VARCHAR(50) DEFAULT 'sistema',
  FOREIGN KEY (`id_presupuesto`) REFERENCES `presupuestos` (`id_presupuesto`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `log_alertas` (
  `id_log` INT AUTO_INCREMENT PRIMARY KEY,
  `id_alerta` INT,
  `accion` ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `campo_modificado` VARCHAR(100),
  `valor_anterior` VARCHAR(255),
  `valor_nuevo` VARCHAR(255),
  `fecha_log` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `usuario` VARCHAR(50) DEFAULT 'sistema',
  FOREIGN KEY (`id_alerta`) REFERENCES `alertas` (`id_alerta`)
    ON DELETE SET NULL ON UPDATE CASCADE
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


