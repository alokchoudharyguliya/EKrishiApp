/**
 * gRPC Client Service for AI Crop Analysis
 * Communicates with Python gRPC server
 */
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');
const path = require('path');

class AIService {
  constructor() {
    // Configuration
    this.grpcServerUrl = process.env.PYTHON_GRPC_URL || 'localhost:50051';
    this.timeout = parseInt(process.env.GRPC_TIMEOUT || '60000'); // 60 seconds
    
    // Load proto file
    const PROTO_PATH = path.join(__dirname, '../protos/crop_analysis.proto');
    
    const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
      keepCase: true,
      longs: String,
      enums: String,
      defaults: true,
      oneofs: true
    });
    
    const cropAnalysisProto = grpc.loadPackageDefinition(packageDefinition).crop_analysis;
    
    // Create gRPC client
    this.client = new cropAnalysisProto.CropAnalysisService(
      this.grpcServerUrl,
      grpc.credentials.createInsecure()
    );
    
    console.log(`[AIService] Initialized. Connecting to Python gRPC server at ${this.grpcServerUrl}`);
  }
  
  /**
   * Analyze crop image and context
   * @param {Buffer} imageBuffer - Image file buffer
   * @param {Object} context - Context data (imageType, cropType, problem, etc.)
   * @returns {Promise<Object>} Analysis result
   */
  async analyzeCrop(imageBuffer, context) {
    return new Promise((resolve, reject) => {
      const deadline = new Date();
      deadline.setSeconds(deadline.getSeconds() + (this.timeout / 1000));
      
      const request = {
        image_data: imageBuffer,
        image_name: context.imageName || 'unknown.jpg',
        image_type: context.imageType || 'Whole Plant',
        crop_type: context.cropType || '',
        observed_problem: context.observedProblem || '',
        plant_age_days: context.plantAge ? parseInt(context.plantAge) : 0,
        recent_weather_event: context.recentWeatherEvent === true || context.recentWeatherEvent === 'true',
        user_id: context.userId || ''
      };
      
      console.log(`[AIService] Sending analysis request to Python server...`);
      console.log(`[AIService] Image size: ${imageBuffer.length} bytes`);
      console.log(`[AIService] Context: ${JSON.stringify(request)}`);
      
      this.client.AnalyzeCrop(
        request,
        { deadline },
        (error, response) => {
          if (error) {
            console.error('[AIService] Error:', error.message);
            
            // Handle specific gRPC errors
            if (error.code === grpc.status.DEADLINE_EXCEEDED) {
              reject(new Error('AI analysis timed out. Please try again.'));
            } else if (error.code === grpc.status.UNAVAILABLE) {
              reject(new Error('AI service is unavailable. Please try again later.'));
            } else {
              reject(new Error(`AI analysis failed: ${error.message}`));
            }
            return;
          }
          
          // Parse response
          const result = {
            success: response.success,
            diagnosis: response.diagnosis,
            confidence: response.confidence,
            disease: response.disease,
            severity: response.severity,
            suggestions: response.suggestions || [],
            treatment: (response.treatment || []).map(t => ({
              product: t.product,
              application: t.application,
              duration: t.duration
            })),
            prevention: response.prevention || [],
            references: response.references || [],
            processingTime: response.processing_time,
            modelUsed: response.model_used,
            errorMessage: response.error_message
          };
          
          console.log(`[AIService] Analysis completed. Success: ${result.success}`);
          
          resolve(result);
        }
      );
    });
  }
  
  /**
   * Health check for AI service
   * @returns {Promise<Object>} Health status
   */
  async healthCheck() {
    return new Promise((resolve, reject) => {
      const deadline = new Date();
      deadline.setSeconds(deadline.getSeconds() + 5); // 5 second timeout for health check
      
      this.client.HealthCheck(
        {},
        { deadline },
        (error, response) => {
          if (error) {
            resolve({
              healthy: false,
              error: error.message,
              status: 'Unavailable'
            });
            return;
          }
          
          resolve({
            healthy: response.healthy,
            status: response.status,
            version: response.version
          });
        }
      );
    });
  }
}

// Export singleton instance
module.exports = new AIService();

