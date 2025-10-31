"""
gRPC Server for AI Crop Analysis Service
Run with: python server.py
"""
import grpc
from concurrent import futures
import time
import sys
import os

# Add protos directory to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), 'protos'))

# Import generated gRPC code
try:
    import crop_analysis_pb2
    import crop_analysis_pb2_grpc
except ImportError:
    print("Error: Generated gRPC code not found. Please run:")
    print("python -m grpc_tools.protoc -I./protos --python_out=. --grpc_python_out=. ./protos/crop_analysis.proto")
    sys.exit(1)

class CropAnalysisServiceServicer(crop_analysis_pb2_grpc.CropAnalysisServiceServicer):
    """Implementation of CropAnalysisService gRPC methods"""
    
    def __init__(self):
        self.model_version = "1.0.0-mock"
    
    def AnalyzeCrop(self, request, context):
        """
        Process crop image and context to provide analysis and recommendations
        
        Args:
            request: CropAnalysisRequest with image and context
            context: gRPC context
        
        Returns:
            CropAnalysisResponse with diagnosis and recommendations
        """
        start_time = time.time()
        
        try:
            print(f"[AI Server] Received analysis request:")
            print(f"  - Image: {request.image_name} ({len(request.image_data)} bytes)")
            print(f"  - Type: {request.image_type}")
            print(f"  - Crop: {request.crop_type}")
            print(f"  - Problem: {request.observed_problem}")
            print(f"  - Age: {request.plant_age_days} days")
            
            # TODO: Replace with actual AI model inference
            # For now, return mock response based on input
            
            # Simulate processing time
            processing_delay = 0.1
            time.sleep(processing_delay)
            
            # Mock analysis result
            diagnosis = self._generate_mock_diagnosis(
                request.crop_type,
                request.observed_problem,
                request.image_type
            )
            
            processing_time = time.time() - start_time
            
            # Build response
            response = crop_analysis_pb2.CropAnalysisResponse(
                success=True,
                diagnosis=diagnosis["diagnosis"],
                confidence=diagnosis["confidence"],
                disease=diagnosis["disease"],
                severity=diagnosis["severity"],
                suggestions=diagnosis["suggestions"],
                treatment=[
                    crop_analysis_pb2.Treatment(
                        product=t["product"],
                        application=t["application"],
                        duration=t["duration"]
                    ) for t in diagnosis["treatment"]
                ],
                prevention=diagnosis["prevention"],
                references=diagnosis["references"],
                processing_time=processing_time,
                model_used=self.model_version
            )
            
            print(f"[AI Server] Analysis completed in {processing_time:.2f}s")
            return response
            
        except Exception as e:
            print(f"[AI Server] Error processing request: {str(e)}")
            processing_time = time.time() - start_time
            
            return crop_analysis_pb2.CropAnalysisResponse(
                success=False,
                error_message=str(e),
                processing_time=processing_time,
                model_used=self.model_version
            )
    
    def HealthCheck(self, request, context):
        """Health check endpoint"""
        return crop_analysis_pb2.HealthResponse(
            healthy=True,
            status="Operational",
            version=self.model_version
        )
    
    def _generate_mock_diagnosis(self, crop_type, problem, image_type):
        """
        Generate mock diagnosis response
        TODO: Replace with actual AI model inference
        """
        # Simple mock logic for demonstration
        if "blight" in problem.lower() or "spot" in problem.lower():
            disease = "Early Blight (Alternaria solani)"
            severity = "moderate"
            suggestions = [
                "Remove affected leaves immediately",
                "Apply copper-based fungicide",
                "Ensure proper plant spacing for air circulation",
                "Water at the base, avoid overhead watering"
            ]
            treatment = [
                {
                    "product": "Copper Fungicide",
                    "application": "Spray every 7-10 days",
                    "duration": "3-4 weeks"
                }
            ]
            confidence = 0.87
        elif "yellow" in problem.lower() or "wilting" in problem.lower():
            disease = "Nutrient Deficiency"
            severity = "low"
            suggestions = [
                "Check soil pH levels",
                "Add organic compost",
                "Apply balanced fertilizer",
                "Ensure proper irrigation"
            ]
            treatment = [
                {
                    "product": "Balanced NPK Fertilizer",
                    "application": "Apply as per package instructions",
                    "duration": "2-3 applications over 4 weeks"
                }
            ]
            confidence = 0.75
        else:
            disease = "General Plant Stress"
            severity = "low"
            suggestions = [
                "Monitor plant conditions closely",
                "Ensure adequate sunlight and water",
                "Check for pests",
                "Maintain proper soil conditions",
           ]
            treatment = [
                {
                    "product": "General Plant Care",
                    "application": "Monitor and adjust growing conditions",
                    "duration": "Ongoing"
                }
            ]
            confidence = 0.65
        
        diagnosis_text = f"Detected {disease} in {crop_type}. {problem}"
        
        return {
            "diagnosis": diagnosis_text,
            "confidence": confidence,
            "disease": disease,
            "severity": severity,
            "suggestions": suggestions,
            "treatment": treatment,
            "prevention": [
                "Regular crop rotation",
                "Use disease-resistant varieties",
                "Proper irrigation timing",
                "Regular monitoring"
            ],
            "references": [
                f"https://agri-research.org/{disease.lower().replace(' ', '-')}",
                "https://plant-care-guide.com/common-issues"
            ]
        }


def serve():
    """Start the gRPC server"""
    # Configuration
    port = os.getenv('GRPC_PORT', '50051')
    max_workers = int(os.getenv('MAX_WORKERS', '10'))
    
    # Create gRPC server
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=max_workers))
    
    # Add servicer
    crop_analysis_pb2_grpc.add_CropAnalysisServiceServicer_to_server(
        CropAnalysisServiceServicer(), server
    )
    
    # Listen on port
    listen_addr = f'[::]:{port}'
    server.add_insecure_port(listen_addr)
    
    # Start server
    server.start()
    print(f"🚀 AI gRPC Server started on port {port}")
    print(f"   Listening on {listen_addr}")
    print(f"   Max workers: {max_workers}")
    print(f"   Ready to accept requests...")
    
    try:
        server.wait_for_termination()
    except KeyboardInterrupt:
        print("\n⚠️  Shutting down server...")
        server.stop(0)
        print("✅ Server stopped")


if __name__ == '__main__':
    serve()

