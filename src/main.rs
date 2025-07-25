mod geometry;
mod stl_output;
mod ui;

use anyhow::Result;
use clap::{Parser, ValueEnum};
use geometry::{RingParameters, RingType};
use stl_output::{generate_stl_file, validate_for_printing, print_manufacturing_info};

#[derive(Parser)]
#[command(name = "optics-ring-generator")]
#[command(about = "Generate 3D printable precision optics support rings")]
#[command(version = "0.1.0")]
struct Cli {
    /// Type of support ring to generate
    #[arg(short, long, value_enum)]
    ring_type: Option<CliRingType>,
    
    /// Outer diameter of the ring in millimeters
    #[arg(short, long)]
    outer_diameter: Option<f32>,
    
    /// Inner diameter of the ring in millimeters
    #[arg(short, long)]
    inner_diameter: Option<f32>,
    
    /// Output directory for STL files (default: current directory)
    #[arg(long)]
    output_dir: Option<String>,
    
    /// Skip 3D printing validation
    #[arg(long)]
    skip_validation: bool,
    
    /// Show detailed manufacturing information
    #[arg(long)]
    manufacturing_info: bool,

    /// Launch interactive UI mode instead of CLI mode
    #[arg(long)]
    ui: bool,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum CliRingType {
    /// Convex support ring (CX) - curves inward toward lens
    #[value(name = "cx")]
    Convex,
    /// Concave support ring (CC) - curves outward from lens
    #[value(name = "cc")]
    Concave,
    /// Three-point support ring (3P) - minimal contact points
    #[value(name = "3p")]
    ThreePoint,
}

impl From<CliRingType> for RingType {
    fn from(cli_type: CliRingType) -> Self {
        match cli_type {
            CliRingType::Convex => RingType::Convex,
            CliRingType::Concave => RingType::Concave,
            CliRingType::ThreePoint => RingType::ThreePoint,
        }
    }
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    
    // Check if UI mode is explicitly requested
    if cli.ui {
        println!("🔬 Starting Optics Ring Generator in interactive mode...");
        println!("Press F1 or 'h' for help, 'q' to quit\n");
        
        // Small delay to let user read the message
        std::thread::sleep(std::time::Duration::from_millis(1500));
        
        return ui::run_ui();
    }
    
    // Check if no CLI arguments provided (default to UI mode)
    if cli.ring_type.is_none() && cli.outer_diameter.is_none() && cli.inner_diameter.is_none() {
        println!("🔬 Starting Optics Ring Generator in interactive mode...");
        println!("Press F1 or 'h' for help, 'q' to quit\n");
        
        // Small delay to let user read the message
        std::thread::sleep(std::time::Duration::from_millis(1500));
        
        return ui::run_ui();
    }
    
    // CLI mode - existing functionality
    println!("Optics Ring Generator v0.1.0");
    println!("============================");
    
    // Validate required CLI arguments
    let ring_type = cli.ring_type.ok_or_else(|| {
        anyhow::anyhow!("Ring type is required. Use --ring-type cx|cc|3p or run with --ui for interactive mode")
    })?;
    
    let outer_diameter = cli.outer_diameter.ok_or_else(|| {
        anyhow::anyhow!("Outer diameter is required. Use --outer-diameter <MM> or run with --ui for interactive mode")
    })?;
    
    let inner_diameter = cli.inner_diameter.ok_or_else(|| {
        anyhow::anyhow!("Inner diameter is required. Use --inner-diameter <MM> or run with --ui for interactive mode")
    })?;
    
    // Create ring parameters
    let ring_type = RingType::from(ring_type);
    let params = RingParameters::new(ring_type, outer_diameter, inner_diameter)?;
    
    // Validate parameters if not skipped
    if !cli.skip_validation {
        validate_for_printing(&params)?;
    }
    
    // Generate STL file
    let output_path = generate_stl_file(&params, cli.output_dir.as_deref())?;
    
    // Show manufacturing information if requested
    if cli.manufacturing_info {
        print_manufacturing_info(&params);
    }
    
    println!("\n✓ Successfully generated: {}", output_path);
    println!("  Ring type: {} ({})", ring_type, match ring_type {
        RingType::Convex => "Convex",
        RingType::Concave => "Concave", 
        RingType::ThreePoint => "Three-point",
    });
    
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_ring_parameters_validation() {
        // Valid parameters
        let params = RingParameters::new(RingType::Convex, 50.0, 25.0);
        assert!(params.is_ok());
        
        // Invalid - outer diameter too small
        let params = RingParameters::new(RingType::Convex, 25.0, 50.0);
        assert!(params.is_err());
        
        // Invalid - negative values
        let params = RingParameters::new(RingType::Convex, -10.0, 5.0);
        assert!(params.is_err());
    }
    
    #[test]
    fn test_filename_generation() {
        let params = RingParameters::new(RingType::Convex, 50.0, 25.0).unwrap();
        assert_eq!(params.filename(), "CX-25.0.stl");
        
        let params = RingParameters::new(RingType::ThreePoint, 40.0, 20.5).unwrap();
        assert_eq!(params.filename(), "3P-20.5.stl");
    }
}
